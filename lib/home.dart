import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/auth.dart';
import 'package:flutter_application_1/drawer.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/music/player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/profile.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

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
      
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.music_note),
            title: Text('----------------------------------------------------------------'),
            subtitle: Text('Название'),
            trailing: IconButton(onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PlayerPage(
                    nameSound: 'Я делаю шаг',
                    author: 'The Hatters',
                    urlMusic: 'https://qklzkuvjpyvdvzzbiltm.supabase.co/storage/v1/object/public/storages//The_Hatters_-_YA_delayu_shag_71431912.mp3',
                    urlPhoto: 'https://qklzkuvjpyvdvzzbiltm.supabase.co/storage/v1/object/public/storages//photo1.webp',
                  )
              ));
            }, icon: Icon(Icons.play_arrow)),
          ),
        ),
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
      
                // Раздел "Альбомы"
                Text(
                  'Треки',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildHorizontalScrollableImages(1, isTracks: true),
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