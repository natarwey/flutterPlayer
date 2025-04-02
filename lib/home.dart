import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/auth.dart';
import 'package:flutter_application_1/database/storage/track.dart';
import 'package:flutter_application_1/database/storage/track_service.dart';
import 'package:flutter_application_1/drawer.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/music/player.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_application_1/profile.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  final SupabaseClient supabase = Supabase.instance.client;
  final TrackService trackService = TrackService();
  List<Track> tracks = [];
  List<Track> filteredTracks = [];
  Track? selectedTrack;
  Track? currentTrack;
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  List<Map<String, dynamic>> authors = [];
  int? selectedAuthorId;

Future<void> _fetchTracks() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedTracks = await trackService.getTracks();

      setState(() {
        tracks = loadedTracks;
        filteredTracks = List.from(loadedTracks);
        if (tracks.isNotEmpty) {
          currentTrack = tracks[0];
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = "Ошибка загрузки треков: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTracks();
    _fetchAuthors();
  }

  Future<void> _fetchAuthors() async {
    try {
      final response = await supabase
          .from('author')
          .select('id, name, image_url');
      
      setState(() {
        authors = response;
      });
    } catch (e) {
      print('Ошибка загрузки исполнителей: $e');
    }
  }

  void _filterByAuthor(int? authorId) {
    setState(() {
      selectedAuthorId = authorId;
      if (authorId == null) {
        filteredTracks = List.from(tracks);
      } else {
        filteredTracks = tracks.where((track) => track.authorId == authorId).toList();
      }
    });
  }

  Widget _buildAuthorsList() {
    if (authors.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Исполнители',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (selectedAuthorId != null)
              TextButton(
                onPressed: () => _filterByAuthor(null),
                child: Text(
                  'Сбросить',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: authors.length,
            itemBuilder: (ctx, index) {
              final author = authors[index];
              return GestureDetector(
                onTap: () => _filterByAuthor(author['id']),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedAuthorId == author['id'] 
                              ? Colors.blue 
                              : Colors.grey[300],
                          image: author['image_url'] != null 
                              ? DecorationImage(
                                  image: NetworkImage(author['image_url']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: author['image_url'] == null
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      SizedBox(height: 5),
                      Text(
                        author['name'],
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedAuthorId == author['id']
                              ? Colors.white
                              : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _filterTracks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTracks = selectedAuthorId == null 
            ? List.from(tracks)
            : tracks.where((t) => t.authorId == selectedAuthorId).toList();
      } else {
        filteredTracks = tracks.where((track) {
          final matchesSearch = track.name.toLowerCase().contains(query.toLowerCase());
          final matchesAuthor = selectedAuthorId == null || track.authorId == selectedAuthorId;
          return matchesSearch && matchesAuthor;
        }).toList();
      }
    });
  }

  void resetSelectedTrack() {
    setState(() {
      selectedTrack = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: DrawerPage(),
        appBar: AppBar(
          title: Text("Home"),
        ),
      
        bottomNavigationBar: selectedTrack != null
            ? GestureDetector(
                onTap: () {
                  if (selectedTrack != null) {
                    _playTrack(selectedTrack!);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: selectedTrack!.imageUrl.isNotEmpty
                        ? Image.network(
                            selectedTrack!.imageUrl, 
                            width: 40, 
                            height: 40,
                          )
                        : const Icon(Icons.music_note),
                    title: Text(selectedTrack!.name),
                    subtitle: FutureBuilder(
                      future: _getAuthorName(selectedTrack!.authorId),
                      builder: (ctx, snapshot) {
                        return Text(snapshot.data ?? 'Unknown Artist');
                      },
                    ),
                    trailing: const Icon(Icons.play_arrow),
                  ),
                ),
              )
            : null,
        
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Поиск...',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: _filterTracks,
                  ),
                ),
                // Раздел "Ваши плейлисты"
                // Text(
                //   'Ваши плейлисты',
                //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                // SizedBox(height: 10),
                // _buildHorizontalScrollableImages(2, isCircle: false),
                // SizedBox(height: 20),
      
                // Раздел "Популярные исполнители"
                _buildAuthorsList(),
                // Text(
                //   'Популярные исполнители',
                //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                // SizedBox(height: 10),
                // _buildHorizontalScrollableImages(1, isCircle: true),
                // SizedBox(height: 20),
      
                // Раздел "Треки"
                Text(
                  'Треки',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildTracksList(),
              ],
            ),
          ),
        ),
      
        //Нижняя панель с кнопками "Назад", "Домой" и "Вперед"
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.white,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       IconButton(
        //         icon: Icon(Icons.arrow_back),
        //         onPressed: () {
        //           Navigator.pop(context); // Возврат на предыдущую страницу
        //         },
        //       ),
        //       IconButton(
        //         icon: Icon(Icons.home),
        //         onPressed: () {
        //           // Переход на главную страницу
        //           Navigator.pushAndRemoveUntil(
        //             context,
        //             MaterialPageRoute(builder: (context) => HomePage()),
        //             (Route<dynamic> route) => false,
        //           );
        //         },
        //       ),
        //       IconButton(
        //         icon: Icon(Icons.arrow_forward),
        //         onPressed: () {
        //           // Переход на следующую страницу
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => HomePage()),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

Widget _buildTracksList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text(errorMessage!));

    if (searchQuery.isNotEmpty && filteredTracks.isEmpty) {
    return Center(
      child: Text(
        'Ничего не найдено по запросу "$searchQuery"',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTracks.length,
      itemBuilder: (ctx, index) {
        final track = filteredTracks[index];
        return ListTile(
          leading: track.imageUrl.isNotEmpty
              ? Image.network(track.imageUrl, width: 50, height: 50)
              : const Icon(Icons.music_note),
          title: Text(track.name),
          subtitle: FutureBuilder(
            future: _getAuthorName(track.authorId),
            builder: (ctx, snapshot) {
              return Text(snapshot.data ?? 'Unknown Artist');
            },
          ),
          onTap: () {
            setState(() {
              selectedTrack = track;
            });
          },
        );
      },
    );
  }

  Future<String> _getAuthorName(int authorId) async {
    final response = await supabase
        .from('author')
        .select('name')
        .eq('id', authorId)
        .single();
    
    return response['name'] as String;
  }

Future<void> _playTrack(Track track) async {
  final authorName = await TrackService().getAuthorName(track.authorId);
  
  if (mounted) {
      setState(() {
        currentTrack = track;
      });
      
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => PlayerPage(
            nameSound: track.name,
            author: authorName,
            urlMusic: track.musicUrl,
            urlPhoto: track.imageUrl,
            onBack: resetSelectedTrack,
          ),
        ),
      );
    }
  }
  
  //Метод для создания прокручиваемых строк с изображениями
  // Widget _buildHorizontalScrollableImages(int numberOfRows, {bool isCircle = false, bool isTracks = false}) {
  //   return Column(
  //     children: List.generate(numberOfRows, (index) {
  //       return Container(
  //         height: 100,
  //         margin: const EdgeInsets.only(bottom: 10),
  //         child: ListView(
  //           scrollDirection: Axis.horizontal,
  //           children: List.generate(10, (index) {
  //             return Container(
  //               width: 100,
  //               height: 100,
  //               margin: const EdgeInsets.symmetric(horizontal: 8),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[300],
  //                 borderRadius: isCircle
  //                     ? BorderRadius.circular(100)
  //                     : BorderRadius.circular(30),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   isCircle
  //                     ? 'Исполнитель ${index + 1}'
  //                     : isTracks
  //                         ? 'Трек ${index + 1}'
  //                         : 'Плейлист ${index + 1}',
  //                   style: const TextStyle(fontSize: 13),
  //                 ),
  //               ),
  //             );
  //           }),
  //         ),
  //       );
  //     }),
  //   );
  // }
}