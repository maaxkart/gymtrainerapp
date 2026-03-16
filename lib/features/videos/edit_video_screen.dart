import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff161A23);

class EditVideoScreen extends StatefulWidget {

  final Map video;

  const EditVideoScreen({super.key, required this.video});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  File? thumbnail;

  List categories = [];
  int? categoryId;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.video["title"];
    descController.text = widget.video["description"];
    categoryId = widget.video["category"]["id"];

    loadCategories();
  }

  Future loadCategories() async {

    final data = await ApiService.getVideoCategories();

    setState(() {
      categories = data;
    });
  }

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

  Future updateVideo() async {

    setState(() => loading = true);

    await ApiService.updateVideo(
      videoId: widget.video["id"],
      categoryId: categoryId!,
      title: titleController.text,
      description: descController.text,
      thumbnail: thumbnail,
    );

    setState(() => loading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Edit Video"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          GestureDetector(
            onTap: pickThumbnail,

            child: Container(
              height: 160,

              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),

              child: thumbnail != null
                  ? Image.file(thumbnail!, fit: BoxFit.cover)
                  : Image.network(
                widget.video["thumbnail"],
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField(
            value: categoryId,
            dropdownColor: card,

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

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Title",
              filled: true,
              fillColor: card,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Description",
              filled: true,
              fillColor: card,
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
            ),

            onPressed: loading ? null : updateVideo,

            child: loading
                ? const CircularProgressIndicator()
                : const Text("Update Video"),
          )
        ],
      ),
    );
  }
}