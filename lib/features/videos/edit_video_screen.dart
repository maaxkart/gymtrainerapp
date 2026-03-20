import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

// ── Brand tokens ──────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF3A4500);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFE0E0);

class EditVideoScreen extends StatefulWidget {
  final Map video;
  const EditVideoScreen({super.key, required this.video});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();

  File? _thumbnail;

  List categories = [];
  int?  categoryId;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text =
        widget.video["title"]?.toString() ?? "";
    _descController.text  =
        widget.video["description"]?.toString() ?? "";
    categoryId =
        (widget.video["category"]?["id"] as num?)?.toInt();
    _titleController.addListener(() => setState(() {}));
    _descController.addListener(()  => setState(() {}));
    _loadCategories();
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

  Future<void> _pickThumbnail() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _thumbnail = File(picked.path));
    }
  }

  Future<void> _updateVideo() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack("Please enter a video title", isError: true);
      return;
    }
    if (categoryId == null) {
      _showSnack("Please select a category", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.updateVideo(
        videoId:     (widget.video["id"] as num?)?.toInt() ?? 0,
        categoryId:  categoryId!,
        title:       _titleController.text.trim(),
        description: _descController.text.trim(),
        thumbnail:   _thumbnail,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
        _showSnack("Update failed. Please try again.", isError: true);
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

  String get _existingThumbnail =>
      widget.video["thumbnail"]?.toString() ?? "";

  String get _categoryName {
    try {
      return categories.firstWhere(
            (c) => (c["id"] as num?)?.toInt() == categoryId,
        orElse: () => {"name": ""},
      )["name"]?.toString() ?? "";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                _buildCurrentVideoCard(),
                const SizedBox(height: 12),
                _buildThumbnailPicker(),
                const SizedBox(height: 12),
                _buildCategoryDropdown(),
                const SizedBox(height: 10),
                _buildTitleField(),
                const SizedBox(height: 10),
                _buildDescField(),
                const SizedBox(height: 12),
                _buildChangesCard(),
                const SizedBox(height: 16),
                _buildUpdateButton(),
                const SizedBox(height: 10),
                _buildDeleteHint(),
              ],
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
                  "Edit Video",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Update your video details",
                  style: TextStyle(color: kText2, fontSize: 10),
                ),
              ],
            ),
          ),
          // Edit badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGoldBorder),
            ),
            child: const Text(
              "EDITING",
              style: TextStyle(
                color: kGoldDark,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CURRENT VIDEO INFO CARD ───────────────────────────
  Widget _buildCurrentVideoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGoldBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Thumbnail preview
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: _existingThumbnail.isNotEmpty
                ? Image.network(
              _existingThumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.video_library_outlined,
                color: Colors.white24,
                size: 28,
              ),
            )
                : const Icon(
              Icons.video_library_outlined,
              color: Colors.white24,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video["title"]?.toString() ?? "Video",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.video["category"]?["name"]?.toString() ?? "",
                  style: const TextStyle(
                      color: kText2, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGoldBorder),
            ),
            child: const Text(
              "LIVE",
              style: TextStyle(
                color: kGoldDark,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── THUMBNAIL PICKER ─────────────────────────────────
  Widget _buildThumbnailPicker() {
    return _SectionWrap(
      label: "Thumbnail",
      child: GestureDetector(
        onTap: _pickThumbnail,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _thumbnail != null ? kGold : kBorder,
              width: _thumbnail != null ? 2 : 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show new thumbnail or existing
              if (_thumbnail != null &&
                  _thumbnail!.existsSync())
                Image.file(
                  _thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(),
                )
              else if (_existingThumbnail.isNotEmpty)
                Image.network(
                  _existingThumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(),
                ),

              // Dark overlay
              Container(color: Colors.black.withOpacity(.4)),

              // Label
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _thumbnail != null
                            ? Icons.check_rounded
                            : Icons.camera_alt_outlined,
                        color: _thumbnail != null
                            ? kGold
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _thumbnail != null
                          ? "New thumbnail selected"
                          : "Tap to change thumbnail",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _thumbnail != null
                          ? "Tap to pick a different one"
                          : "Current thumbnail shown above",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // "NEW" badge when changed
              if (_thumbnail != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "NEW THUMBNAIL",
                      style: TextStyle(
                        color: kGoldDeep,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CATEGORY DROPDOWN ────────────────────────────────
  Widget _buildCategoryDropdown() {
    return _SectionWrap(
      label: "Category",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryId != null ? kGoldBorder : kBorder,
            width: categoryId != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kGoldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_outlined,
                  color: kGoldDark, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value:         categoryId,
                  isExpanded:    true,
                  dropdownColor: kSurface,
                  borderRadius:  BorderRadius.circular(16),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: kText2,
                  ),
                  hint: const Text(
                    "Select category",
                    style: TextStyle(
                        color: kText2, fontSize: 14),
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
                            fontWeight: FontWeight.w500,
                          )),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => categoryId = v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TITLE FIELD ──────────────────────────────────────
  Widget _buildTitleField() {
    final len = _titleController.text.length;
    return _SectionWrap(
      label: "Video Title",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: len > 0 ? kGoldBorder : kBorder,
            width: len > 0 ? 1.5 : 1,
          ),
        ),
        child: Column(
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
                  "TITLE",
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
                hintText:       "Video title",
                hintStyle:      TextStyle(
                    color: kText2,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                border:         InputBorder.none,
                isDense:        true,
                contentPadding: EdgeInsets.zero,
                counterText:    "",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DESCRIPTION FIELD ────────────────────────────────
  Widget _buildDescField() {
    final len = _descController.text.length;
    return _SectionWrap(
      label: "Description",
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        kSurface,
          borderRadius: BorderRadius.circular(18),
          border:       Border.all(color: kBorder),
        ),
        child: Column(
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
                hintStyle:      TextStyle(
                    color: kText2, fontSize: 14),
                border:         InputBorder.none,
                isDense:        true,
                contentPadding: EdgeInsets.zero,
                counterText:    "",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CHANGES SUMMARY CARD ─────────────────────────────
  Widget _buildChangesCard() {
    final hasNewThumb = _thumbnail != null;
    final titleChanged =
        _titleController.text.trim() !=
            (widget.video["title"]?.toString() ?? "").trim();
    final descChanged =
        _descController.text.trim() !=
            (widget.video["description"]?.toString() ?? "").trim();
    final catChanged =
        categoryId !=
            (widget.video["category"]?["id"] as num?)?.toInt();

    final changes = [
      if (hasNewThumb)  "New thumbnail",
      if (titleChanged) "Title updated",
      if (descChanged)  "Description updated",
      if (catChanged)   "Category changed",
    ];

    if (changes.isEmpty) return const SizedBox.shrink();

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
            child: const Icon(Icons.edit_note_rounded,
                color: kGoldDeep, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pending Changes",
                  style: TextStyle(
                    color:      kGoldDeep,
                    fontSize:   12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  changes.join(" · "),
                  style: const TextStyle(
                    color:    kGoldDark,
                    fontSize: 11,
                    height:   1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── UPDATE BUTTON ─────────────────────────────────────
  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: loading ? null : _updateVideo,
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
                  : const Icon(Icons.save_rounded,
                  color: kGoldDeep, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Save Changes",
                    style: TextStyle(
                      color:        kGoldDeep,
                      fontSize:     15,
                      fontWeight:   FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Update video details for members",
                    style: TextStyle(
                        color: kGoldDark, fontSize: 11),
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

  // ── DELETE HINT ───────────────────────────────────────
  Widget _buildDeleteHint() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: kSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Delete Video",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
              content: const Text(
                "This will permanently remove the video from your library.",
                style: TextStyle(color: kText2, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel",
                      style: TextStyle(color: kText2)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("Delete",
                        style: TextStyle(
                          color:      kSurface,
                          fontSize:   13,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          );

          if (confirm == true && mounted) {
            await ApiService.deleteVideo(
                (widget.video["id"] as num?)?.toInt() ?? 0);
            if (mounted) Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete_outline_rounded,
                  color: kRed, size: 16),
              SizedBox(width: 6),
              Text(
                "Delete this video",
                style: TextStyle(
                  color:      kRed,
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SECTION WRAP ─────────────────────────────────────────────
class _SectionWrap extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionWrap({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          color:        kText2,
          fontSize:     10,
          fontWeight:   FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}