import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../../services/api_service.dart';

// ── Brand tokens ──────────────────────────────────────
const kGold        = Color(0xFFC8DC32);
const kGoldDark    = Color(0xFF8FA000);
const kGoldDeep    = Color(0xFF3A4500);
const kGoldLight   = Color(0xFFF5F8D6);
const kGoldBorder  = Color(0xFFE2EC8A);
const kBg          = Color(0xFFF7F7F5);
const kSurface     = Color(0xFFFFFFFF);
const kSurface2    = Color(0xFFF5F5F5);
const kBorder      = Color(0xFFEFEFEF);
const kText1       = Color(0xFF111111);
const kText2       = Color(0xFFAAAAAA);
const kRed         = Color(0xFFE53935);
const kRedBg       = Color(0xFFFFF3F3);

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();

  File? _videoFile;
  File? _thumbnail;

  List categories = [];
  int? categoryId;
  String _categoryName = "";

  bool   loading        = false;
  double uploadProgress = 0;
  String _statusMsg     = "";

  // Step: 0=media, 1=details, 2=uploading
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _titleController.addListener(() => setState(() {}));
    _descController.addListener(()  => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.getVideoCategories();
      if (mounted) setState(() => categories = (data as List?) ?? []);
    } catch (_) {}
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _videoFile = File(picked.path);
        if (_step == 0) _step = 1;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _thumbnail = File(picked.path));
    }
  }

  Future<File> _compressVideo(File video) async {
    final info = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality,
    );
    return File(info!.path!);
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      _showSnack("Please select a workout video", isError: true);
      return;
    }
    if (_thumbnail == null) {
      _showSnack("Please select a thumbnail image", isError: true);
      return;
    }
    if (categoryId == null) {
      _showSnack("Please select a category", isError: true);
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showSnack("Please enter a video title", isError: true);
      return;
    }

    setState(() {
      loading        = true;
      uploadProgress = 0;
      _statusMsg     = "Compressing video…";
      _step          = 2;
    });

    try {
      final compressed = await _compressVideo(_videoFile!);
      if (mounted) setState(() => _statusMsg = "Uploading to server…");

      await ApiService.uploadVideoWithProgress(
        categoryId:  categoryId!,
        title:       _titleController.text.trim(),
        description: _descController.text.trim(),
        video:       compressed,
        thumbnail:   _thumbnail!,
        onProgress:  (p) {
          if (mounted) setState(() => uploadProgress = p);
        },
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; _step = 1; _statusMsg = ""; });
        _showSnack("Upload failed. Please try again.", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
                color: isError ? kRed : kGoldDeep,
                fontWeight: FontWeight.w600)),
        backgroundColor: isError ? kRedBg : kGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _videoFileName => _videoFile != null
      ? _videoFile!.path.split("/").last
      : "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              _buildStepIndicator(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _buildVideoZone(),
                    const SizedBox(height: 12),
                    _buildMediaRow(),
                    const SizedBox(height: 12),
                    _buildTitleField(),
                    const SizedBox(height: 10),
                    _buildDescField(),
                    const SizedBox(height: 12),
                    _buildProTip(),
                    const SizedBox(height: 8),
                    if (loading) _buildProgressCard(),
                    if (loading) const SizedBox(height: 12),
                    _buildUploadButton(),
                  ],
                ),
              ),
            ],
          ),

          // Full-screen upload overlay
          if (loading)
            Container(
              color: Colors.black.withOpacity(.65),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: kGoldLight,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.upload_rounded,
                          color: kGoldDark,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Uploading Video",
                        style: TextStyle(
                          color: kText1,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _statusMsg,
                        style: const TextStyle(
                            color: kText2, fontSize: 12),
                      ),

                      const SizedBox(height: 28),

                      // Progress percentage — large
                      Text(
                        "${(uploadProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:           uploadProgress.clamp(0.0, 1.0),
                          minHeight:       12,
                          backgroundColor: kGoldLight,
                          valueColor: const AlwaysStoppedAnimation(kGold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Step labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ProgressStep("Compress", uploadProgress >= 0.1),
                          _ProgressStep("Upload",   uploadProgress >= 0.5),
                          _ProgressStep("Publish",  uploadProgress >= 0.99),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: kBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: kText1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Upload Video",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Share your workout with members",
                  style: TextStyle(color: kText2, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP INDICATOR ────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          _StepItem(number: 1, label: "Media",   state: _step > 0 ? _StepState.done : _step == 0 ? _StepState.active : _StepState.idle),
          _StepItem(number: 2, label: "Details", state: _step > 1 ? _StepState.done : _step == 1 ? _StepState.active : _StepState.idle),
          _StepItem(number: 3, label: "Upload",  state: _step > 2 ? _StepState.done : _step == 2 ? _StepState.active : _StepState.idle),
        ],
      ),
    );
  }

  // ── VIDEO HERO ZONE ───────────────────────────────────
  Widget _buildVideoZone() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color:        const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(
            color: _videoFile != null ? kGold : kBorder,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail preview if available
            if (_thumbnail != null && _thumbnail!.existsSync())
              Image.file(
                _thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            // Dark overlay
            Container(
              color: Colors.black.withOpacity(
                  _thumbnail != null ? .45 : .0),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _videoFile != null
                          ? Icons.play_arrow_rounded
                          : Icons.video_call_outlined,
                      color: kGoldDeep,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _videoFile != null
                        ? _videoFileName
                        : "Tap to select workout video",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _videoFile != null
                        ? "Tap to change"
                        : "MP4 · MOV · AVI supported",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Selected badge
            if (_videoFile != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text(
                    "VIDEO SELECTED",
                    style: TextStyle(
                      color: kGoldDeep,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── MEDIA ROW: Thumbnail + Category ──────────────────
  Widget _buildMediaRow() {
    return Row(
      children: [
        // Thumbnail
        Expanded(
          child: GestureDetector(
            onTap: _pickThumbnail,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color:        _thumbnail != null
                    ? const Color(0xFF1A1A1A)
                    : kGoldLight,
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(
                  color: _thumbnail != null ? kGold : kGoldBorder,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _thumbnail == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_outlined,
                        color: kGoldDark, size: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text("Thumbnail",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              )
                  : Stack(
                fit: StackFit.expand,
                children: [
                  if (_thumbnail != null && _thumbnail!.existsSync())
                    Image.file(
                      _thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: kGoldLight),
                    ),
                  Container(color: Colors.black38),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 20),
                      SizedBox(height: 4),
                      Text("Change",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Category
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        kSurface,
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(
                color: categoryId != null ? kGoldBorder : kBorder,
                width: categoryId != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kGoldLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.category_outlined,
                          color: kGoldDark, size: 14),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      "CATEGORY",
                      style: TextStyle(
                        color: kText2,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                // Inline dropdown
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value:         categoryId,
                    isExpanded:    true,
                    isDense:       true,
                    dropdownColor: kSurface,
                    borderRadius:  BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: kText2, size: 18),
                    hint: const Text("Select",
                        style: TextStyle(
                            color: kText2,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    style: const TextStyle(
                      color: kGoldDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Syne',
                    ),
                    items: categories.map<DropdownMenuItem<int>>((raw) {
                      final c  = Map<String, dynamic>.from(
                          raw as Map? ?? {});
                      final id = (c["id"] as num?)?.toInt() ?? 0;
                      final nm = c["name"]?.toString() ?? "";
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(nm,
                            style: const TextStyle(
                              color: kText1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                      );
                    }).toList(),
                    onChanged: (v) {
                      final nm = categories.firstWhere(
                            (e) => (e["id"] as num?)?.toInt() == v,
                        orElse: () => {"name": ""},
                      )["name"]?.toString() ?? "";
                      setState(() {
                        categoryId    = v;
                        _categoryName = nm;
                      });
                    },
                  ),
                ),

                Text(
                  categoryId != null
                      ? "Tap to change"
                      : "Required field",
                  style: TextStyle(
                    color:    categoryId != null ? kText2 : kRed,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── TITLE FIELD ──────────────────────────────────────
  Widget _buildTitleField() {
    final len = _titleController.text.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        kSurface,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(
          color: len > 0 ? kGoldBorder : kBorder,
          width: len > 0 ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kGoldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.title_rounded,
                    color: kGoldDark, size: 15),
              ),
              const SizedBox(width: 10),
              const Text(
                "VIDEO TITLE",
                style: TextStyle(
                  color: kGoldDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                "$len / 100",
                style: const TextStyle(
                    color: kText2, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            maxLength:  100,
            style: const TextStyle(
              color:      kText1,
              fontSize:   16,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              hintText:       "e.g. Full Body Squat Tutorial",
              hintStyle:      TextStyle(
                  color: kText2, fontSize: 16, fontWeight: FontWeight.w400),
              border:         InputBorder.none,
              isDense:        true,
              contentPadding: EdgeInsets.zero,
              counterText:    "",
            ),
          ),
        ],
      ),
    );
  }

  // ── DESCRIPTION FIELD ────────────────────────────────
  Widget _buildDescField() {
    final len = _descController.text.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        kSurface,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kGoldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notes_rounded,
                    color: kGoldDark, size: 15),
              ),
              const SizedBox(width: 10),
              const Text(
                "DESCRIPTION",
                style: TextStyle(
                  color: kText2,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                "$len / 300",
                style: const TextStyle(
                    color: kText2, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            maxLines:   4,
            maxLength:  300,
            style: const TextStyle(
              color:      kText1,
              fontSize:   14,
              fontWeight: FontWeight.w400,
              height:     1.5,
            ),
            decoration: const InputDecoration(
              hintText:       "Describe your workout video…",
              hintStyle:      TextStyle(color: kText2, fontSize: 14),
              border:         InputBorder.none,
              isDense:        true,
              contentPadding: EdgeInsets.zero,
              counterText:    "",
            ),
          ),
        ],
      ),
    );
  }

  // ── PRO TIP ──────────────────────────────────────────
  Widget _buildProTip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        kGoldLight,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: kGoldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: kGoldDeep, size: 14),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pro Tip",
                  style: TextStyle(
                    color:      kGoldDeep,
                    fontSize:   12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Videos are automatically compressed before upload. A clear, high-contrast thumbnail gets 3× more clicks from members.",
                  style: TextStyle(
                    color:  kGoldDark,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS CARD (inline) ───────────────────────────
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        kGoldLight,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: kGoldBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_statusMsg,
                  style: const TextStyle(
                    color:      kGoldDark,
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                  )),
              Text(
                "${(uploadProgress * 100).toInt()}%",
                style: const TextStyle(
                  color:      kGoldDeep,
                  fontSize:   14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:           uploadProgress.clamp(0.0, 1.0),
              minHeight:       8,
              backgroundColor: kSurface,
              valueColor: const AlwaysStoppedAnimation(kGold),
            ),
          ),
        ],
      ),
    );
  }

  // ── UPLOAD BUTTON ────────────────────────────────────
  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: loading ? null : _uploadVideo,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: loading ? kGold.withOpacity(.7) : kGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: loading
                  ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:       kGoldDeep,
                ),
              )
                  : const Icon(Icons.upload_rounded,
                  color: kGoldDeep, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upload Video",
                    style: TextStyle(
                      color:        kGoldDeep,
                      fontSize:     15,
                      fontWeight:   FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Compress & publish to members",
                    style: TextStyle(
                      color:    kGoldDark,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: kGoldDeep, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PROGRESS STEP LABEL ───────────────────────────────────────
class _ProgressStep extends StatelessWidget {
  final String label;
  final bool   done;
  const _ProgressStep(this.label, this.done);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color:  done ? kGold : kSurface2,
          shape:  BoxShape.circle,
          border: Border.all(
              color: done ? kGold : kBorder, width: 1.5),
        ),
        child: done
            ? const Icon(Icons.check_rounded,
            size: 9, color: kGoldDeep)
            : null,
      ),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
            color:      done ? kGoldDark : kText2,
            fontSize:   11,
            fontWeight: FontWeight.w600,
          )),
    ],
  );
}

// ── STEP INDICATOR ITEM ───────────────────────────────────────
enum _StepState { done, active, idle }

class _StepItem extends StatelessWidget {
  final int        number;
  final String     label;
  final _StepState state;

  const _StepItem({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state != _StepState.idle;
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:        isActive ? kGold : kSurface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: state == _StepState.done
                    ? const Icon(Icons.check_rounded,
                    size: 12, color: kGoldDeep)
                    : Text(
                  number.toString(),
                  style: TextStyle(
                    color:      isActive ? kGoldDeep : kText2,
                    fontSize:   11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color:      isActive ? kGoldDark : kText2,
                  fontSize:   11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              color:        isActive ? kGold : kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}