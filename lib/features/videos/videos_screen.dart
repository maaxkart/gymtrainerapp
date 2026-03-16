import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../services/api_service.dart';
import '../videos/add_video_screen.dart';
import '../videos/video_player_screen.dart';
import '../videos/edit_video_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff161A23);

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {

  List categories = [];
  List videos = [];

  int? selectedCategory;

  bool loading = true;

  final RefreshController refreshController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {

    final cats = await ApiService.getVideoCategories();
    final vids = await ApiService.getMyVideos();

    setState(() {
      categories = cats;
      videos = vids;
      loading = false;
    });
  }

  List get filteredVideos {

    if (selectedCategory == null) return videos;

    return videos.where((v) {
      return v["category"]["id"] == selectedCategory;
    }).toList();
  }

  Future deleteVideo(int id) async {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        title: const Text("Delete Video",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this video?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {

              Navigator.pop(context);

              await ApiService.deleteVideo(id);

              loadData();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Trainer Videos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Upload",
          style: TextStyle(color: Colors.black),
        ),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddVideoScreen(),
            ),
          );

          loadData();
        },
      ),

      body: loading
          ? const Center(
          child: CircularProgressIndicator(color: gold))
          : Column(
        children: [

          /// CATEGORY FILTER
          SizedBox(
            height: 50,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 16),

              itemCount: categories.length,

              itemBuilder: (_, i) {

                final cat = categories[i];
                final selected =
                    selectedCategory == cat["id"];

                return GestureDetector(

                  onTap: () {

                    setState(() {

                      selectedCategory =
                      selected ? null : cat["id"];
                    });
                  },

                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 250),

                    margin:
                    const EdgeInsets.only(right: 10),

                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),

                    decoration: BoxDecoration(
                      color: selected
                          ? gold
                          : Colors.white10,

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Center(
                      child: Text(
                        cat["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// VIDEO LIST
          Expanded(
            child: SmartRefresher(
              controller: refreshController,

              onRefresh: () async {

                await loadData();

                refreshController.refreshCompleted();
              },

              child: filteredVideos.isEmpty
                  ? const Center(
                child: Text(
                  "No videos uploaded yet",
                  style: TextStyle(
                      color: Colors.white54),
                ),
              )
                  : GridView.builder(

                padding: const EdgeInsets.all(16),

                itemCount: filteredVideos.length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),

                itemBuilder: (_, i) {

                  final video = filteredVideos[i];

                  return GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VideoPlayerScreen(
                                  url: video["video_url"]),
                        ),
                      );
                    },

                    child: Container(

                      decoration: BoxDecoration(
                        color: card,
                        borderRadius:
                        BorderRadius.circular(16),
                      ),

                      child: Stack(
                        children: [

                          /// THUMBNAIL
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(16),

                              child: Image.network(
                                video["thumbnail"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          /// GRADIENT
                          Positioned.fill(
                            child: Container(
                              decoration:
                              const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black87
                                  ],
                                  begin:
                                  Alignment.topCenter,
                                  end: Alignment
                                      .bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          /// PLAY ICON
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),

                          /// EDIT BUTTON
                          Positioned(
                            top: 8,
                            right: 40,

                            child: GestureDetector(

                              onTap: () async {

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditVideoScreen(
                                            video:
                                            video),
                                  ),
                                );

                                loadData();
                              },

                              child: Container(
                                padding:
                                const EdgeInsets.all(
                                    6),

                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      20),
                                ),

                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          /// DELETE BUTTON
                          Positioned(
                            top: 8,
                            right: 8,

                            child: GestureDetector(

                              onTap: () =>
                                  deleteVideo(
                                      video["id"]),

                              child: Container(
                                padding:
                                const EdgeInsets.all(
                                    6),

                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      20),
                                ),

                                child: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          /// CATEGORY
                          Positioned(
                            top: 8,
                            left: 8,

                            child: Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                  horizontal: 8,
                                  vertical: 4),

                              decoration: BoxDecoration(
                                color: gold,
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                              ),

                              child: Text(
                                video["category"]
                                ["type"]
                                    .toUpperCase(),

                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    Colors.black),
                              ),
                            ),
                          ),

                          /// TITLE
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,

                            child: Text(
                              video["title"],
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}