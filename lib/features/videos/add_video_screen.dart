import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff161A23);

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  File? videoFile;
  File? thumbnail;

  List categories = [];
  int? categoryId;

  bool loading = false;
  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  /// LOAD VIDEO CATEGORIES
  Future loadCategories() async {

    final data = await ApiService.getVideoCategories();

    setState(() {
      categories = data;
    });
  }

  /// PICK VIDEO
  Future pickVideo() async {

    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        videoFile = File(picked.path);
      });
    }
  }

  /// PICK THUMBNAIL
  Future pickThumbnail() async {

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        thumbnail = File(picked.path);
      });
    }
  }

  /// COMPRESS VIDEO
  Future<File> compressVideo(File video) async {

    final info = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality,
    );

    return File(info!.path!);
  }

  /// UPLOAD VIDEO
  Future uploadVideo() async {

    if (videoFile == null ||
        thumbnail == null ||
        categoryId == null ||
        titleController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );

      return;
    }

    setState(() {
      loading = true;
      uploadProgress = 0;
    });

    try {

      /// STEP 1 COMPRESS VIDEO
      File compressedVideo = await compressVideo(videoFile!);

      /// STEP 2 UPLOAD
      await ApiService.uploadVideoWithProgress(

        categoryId: categoryId!,
        title: titleController.text,
        description: descController.text,
        video: compressedVideo,
        thumbnail: thumbnail!,

        onProgress: (progress) {

          setState(() {
            uploadProgress = progress;
          });

        },
      );

      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {

      print("UPLOAD ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );

    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Upload Video"),
      ),

      body: Stack(
        children: [

          ListView(
            padding: const EdgeInsets.all(20),
            children: [

              /// VIDEO PICKER
              GestureDetector(
                onTap: pickVideo,

                child: Container(
                  height: 160,

                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: videoFile == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(Icons.video_call,
                            size: 40,
                            color: gold),

                        SizedBox(height: 10),

                        Text(
                          "Select Workout Video",
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Icon(
                        Icons.check_circle,
                        color: gold,
                        size: 40,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        videoFile!.path.split("/").last,
                        style: const TextStyle(color: Colors.white70),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// THUMBNAIL PICKER
              GestureDetector(
                onTap: pickThumbnail,

                child: Container(
                  height: 160,

                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: thumbnail == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(Icons.image,
                            size: 35,
                            color: gold),

                        SizedBox(height: 8),

                        Text(
                          "Select Thumbnail",
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(18),

                    child: Image.file(
                      thumbnail!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// CATEGORY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: DropdownButton(
                  value: categoryId,
                  dropdownColor: card,
                  underline: const SizedBox(),

                  hint: const Text(
                    "Select Category",
                    style: TextStyle(color: Colors.white),
                  ),

                  isExpanded: true,

                  items: categories.map((c) {

                    return DropdownMenuItem(
                      value: c["id"],
                      child: Text(
                        c["name"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );

                  }).toList(),

                  onChanged: (val) {

                    setState(() {
                      categoryId = val as int;
                    });

                  },
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              TextField(
                controller: titleController,

                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: "Video Title",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: card,
                ),
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
              TextField(
                controller: descController,
                maxLines: 4,

                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: card,
                ),
              ),

              const SizedBox(height: 30),

              /// UPLOAD BUTTON
              SizedBox(
                height: 50,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: loading ? null : uploadVideo,

                  child: const Text(
                    "Upload Video",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),

          /// UPLOAD PROGRESS OVERLAY
          if (loading)
            Container(
              color: Colors.black87,

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      "Uploading Video",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18),
                    ),

                    const SizedBox(height: 30),

                    CircularPercentIndicator(
                      radius: 90,
                      lineWidth: 12,
                      percent: uploadProgress.clamp(0.0, 1.0),
                      animation: true,
                      animationDuration: 500,
                      center: Text(
                        "${(uploadProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      progressColor: gold,
                      backgroundColor: Colors.white24,
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}