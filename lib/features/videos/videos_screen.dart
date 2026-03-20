import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../services/api_service.dart';
import '../videos/add_video_screen.dart';
import '../videos/video_player_screen.dart';
import '../videos/edit_video_screen.dart';

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

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List categories       = [];
  List videos           = [];
  int? selectedCategory;
  bool loading          = true;

  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cats = await ApiService.getVideoCategories();
      final vids = await ApiService.getMyVideos();
      if (mounted) {
        setState(() {
          categories = (cats as List?) ?? [];
          videos     = (vids as List?) ?? [];
          loading    = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  List get _filteredVideos {
    if (selectedCategory == null) return videos;
    return videos.where((v) {
      return (v["category"]?["id"] as num?)?.toInt() == selectedCategory;
    }).toList();
  }

  Future<void> _deleteVideo(dynamic video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Video",
          style: TextStyle(
            color: kText1,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Delete "${(video["title"] ?? "this video").toString()}"?',
          style: const TextStyle(color: kText2, fontSize: 13),
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
                    color: kSurface,
                    fontSize: 13,
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
          (video["id"] as num?)?.toInt() ?? 0);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              if (loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: kGold, strokeWidth: 2.5),
                  ),
                )
              else
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      await _loadData();
                      _refreshController.refreshCompleted();
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 100),
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 14),
                        _buildCategoryFilter(),
                        const SizedBox(height: 14),
                        _buildSectionLabel(),
                        _filteredVideos.isEmpty
                            ? _buildEmptyState()
                            : _buildGrid(),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Premium FAB
          Positioned(
            bottom: 28,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddVideoScreen()),
                );
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kGold.withOpacity(.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.upload_rounded,
                        color: kGoldDeep, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Upload Video",
                      style: TextStyle(
                        color: kGoldDeep,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
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
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(12),
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
          const Expanded(
            child: Text(
              "Trainer Videos",
              style: TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Video count badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGoldBorder),
            ),
            child: Text(
              "${videos.length} Videos",
              style: const TextStyle(
                color: kGoldDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGold,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TOTAL VIDEOS",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${videos.length} Video${videos.length == 1 ? '' : 's'}",
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${categories.length} categories available",
                  style: const TextStyle(
                    color: kGoldDeep,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.video_library_outlined,
              color: kText1,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY FILTER ───────────────────────────────────
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" pill
          _CategoryPill(
            label: "All",
            isActive: selectedCategory == null,
            onTap: () => setState(() => selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...categories.map((cat) {
            final id       = (cat["id"] as num?)?.toInt();
            final isActive = selectedCategory == id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryPill(
                label:    cat["name"]?.toString() ?? "",
                isActive: isActive,
                onTap: () => setState(() =>
                selectedCategory = isActive ? null : id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() => const Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "ALL VIDEOS",
      style: TextStyle(
        color: kText2,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );

  // ── VIDEO GRID ────────────────────────────────────────
  Widget _buildGrid() {
    final vids = _filteredVideos;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.82,
      ),
      itemCount: vids.length,
      itemBuilder: (_, i) {
        final video = vids[i];
        return _VideoCard(
          video:    video,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                  url: video["video_url"]?.toString() ?? ""),
            ),
          ),
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditVideoScreen(video: video),
              ),
            );
            _loadData();
          },
          onDelete: () => _deleteVideo(video),
        );
      },
    );
  }

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.video_library_outlined,
                color: kGoldDark, size: 30),
          ),
          const SizedBox(height: 14),
          const Text("No videos uploaded yet",
              style: TextStyle(color: kText2, fontSize: 13)),
          const SizedBox(height: 6),
          const Text("Tap Upload Video to get started",
              style: TextStyle(color: kText2, fontSize: 11)),
        ],
      ),
    ),
  );
}

// ── CATEGORY PILL ─────────────────────────────────────────────
class _CategoryPill extends StatelessWidget {
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? kGold : kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? kGold : kBorder,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? kGoldDeep : kText2,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

// ── VIDEO CARD ────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final dynamic      video;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VideoCard({
    required this.video,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String thumbnail  = video["thumbnail"]?.toString()          ?? "";
    final String title      = video["title"]?.toString()              ?? "Untitled";
    final String categoryType = (video["category"]?["type"]?.toString() ?? "").toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Thumbnail
            thumbnail.isNotEmpty
                ? Image.network(
              thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1E1E1E),
                child: const Icon(
                  Icons.video_library_outlined,
                  color: Colors.white24,
                  size: 36,
                ),
              ),
            )
                : Container(
              color: const Color(0xFF1E1E1E),
              child: const Icon(
                Icons.video_library_outlined,
                color: Colors.white24,
                size: 36,
              ),
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Play button
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: kGoldDeep,
                  size: 28,
                ),
              ),
            ),

            // Category badge — top left
            if (categoryType.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    categoryType,
                    style: const TextStyle(
                      color: kGoldDeep,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),

            // Edit + Delete buttons — top right
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  // Edit
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Delete
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 14,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title — bottom
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}