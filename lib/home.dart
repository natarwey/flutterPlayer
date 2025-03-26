import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/auth.dart';
import 'package:flutter_application_1/database/storage/track.dart';
import 'package:flutter_application_1/database/storage/track_service.dart';
import 'package:flutter_application_1/drawer.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/music/player.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_application_1/profile.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  //final TextEditingController _searchController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  final TrackService trackService = TrackService();
  List<Track> tracks = [];
  Track? currentTrack;
  bool isLoading = true;
  String? errorMessage;

Future<void> _fetchTracks() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedTracks = await trackService.getTracks();

      setState(() {
        tracks = loadedTracks;
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
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        automaticallyImplyLeading: false,
          title: Text("Home"),
          //leading: IconButton(
            // icon: Icon(Icons.person, color: Colors.white),
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (context) => ProfilePage(
            //         userName: 'Рената',
            //         userEmail: 'natarwey.basharova@yandex.ru',
            //         userPhotoUrl: 'https://qklzkuvjpyvdvzzbiltm.supabase.co/storage/v1/object/public/storages//profil.webp',
            //       ),
            //     ),
            //   );
            // },
          //),
          actions: [
            IconButton(
              onPressed: () async {
                await authService.logOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.popAndPushNamed(context, '/');
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              )
          ]
        ),
      
        bottomNavigationBar: currentTrack != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  leading: currentTrack!.imageUrl.isNotEmpty
                      ? Image.network(currentTrack!.imageUrl, width: 40, height: 40)
                      : const Icon(Icons.music_note),
                  title: Text(currentTrack!.name),
                  trailing: IconButton(
                    onPressed: () => _playTrack(currentTrack!),
                    icon: const Icon(Icons.play_arrow),
                  ),
                ),
              )
            : null,
        drawer: DrawerPage(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Раздел "Ваши плейлисты"
                Text(
                  'Ваши плейлисты',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildHorizontalScrollableImages(2, isCircle: false),
                SizedBox(height: 20),
      
                // Раздел "Популярные исполнители"
                Text(
                  'Популярные исполнители',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildHorizontalScrollableImages(1, isCircle: true),
                SizedBox(height: 20),
      
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
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (ctx, index) {
        final track = tracks[index];
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
          onTap: () => _playTrack(track),
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

void _playTrack(Track track) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => PlayerPage(
          nameSound: track.name,
          author: 'Loading...',
          urlMusic: track.musicUrl,
          urlPhoto: track.imageUrl,
        ),
      ),
    );
  }
  
  //Метод для создания прокручиваемых строк с изображениями
  Widget _buildHorizontalScrollableImages(int numberOfRows, {bool isCircle = false, bool isTracks = false}) {
    return Column(
      children: List.generate(numberOfRows, (index) {
        return Container(
          height: 100,
          margin: EdgeInsets.only(bottom: 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(10, (index) {
              return Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: isCircle
                      ? BorderRadius.circular(100)
                      : BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    isCircle
                      ? 'Исполнитель ${index + 1}'
                      : isTracks
                          ? 'Трек ${index + 1}'
                          : 'Плейлист ${index + 1}',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}