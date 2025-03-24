import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  final String user_id =
      Supabase.instance.client.auth.currentUser!.id.toString();
  dynamic docs;

  getUserById()async{
    final userGet = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user_id)
        .single();
    setState(() {
      docs = userGet;
    });

  }
  @override
  void initState() {
    getUserById();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white10
              ),
              accountName: Text(docs['name']),
              accountEmail: Text(docs['email']),
              currentAccountPicture: Container(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  maxRadius: 20,
                  minRadius: 10,
                  backgroundImage: NetworkImage(
                    'https://qklzkuvjpyvdvzzbiltm.supabase.co/storage/v1/object/public/storages//profil.webp'),
                ),
              ),
              otherAccountsPictures: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.logout),
                )
              ],
            )
          ),
          ListTile(
            iconColor: Colors.red,
            textColor: Colors.white,
            title: Text("Моя музыка"),
            leading: Icon(Icons.music_note),
            onTap: () {},
          ),
          ListTile(
            iconColor: Colors.yellow,
            textColor: Colors.white,
            title: Text("Плейлисты"),
            leading: Icon(Icons.featured_play_list),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}