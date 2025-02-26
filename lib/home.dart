import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool isPlaying = false; // Состояние воспроизведения (играет/на паузе)
  double playbackProgress = 0.5; // Прогресс воспроизведения (от 0.0 до 1.0)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Навигация на страницу личного аккаунта
            },
          ),
        ],
      ),
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
                'Альбомы',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildHorizontalScrollableImages(1, isAlbums: true),
            ],
          ),
        ),
      ),

      // Панель проигрывания трека внизу экрана
      bottomSheet: Container(
        height: 80,
        color:  Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: playbackProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.music_note, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Название трека', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Исполнитель', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_previous, color: Colors.grey[700]),
                  onPressed: () {
                    // Действие при нажатии на кнопку "назад"
                  },
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying; // Переключение состояния воспроизведения
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.grey[700]),
                  onPressed: () {
                    // Действие при нажатии на кнопку "вперед"
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // Нижняя панель с кнопками "Назад", "Домой" и "Вперед"
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Возврат на предыдущую страницу
              },
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Переход на главную страницу
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                // Переход на следующую страницу
                // Замените NextPage() на вашу следующую страницу
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Метод для создания прокручиваемых строк с изображениями
  Widget _buildHorizontalScrollableImages(int numberOfRows, {bool isCircle = false, bool isAlbums = false}) {
    return Column(
      children: List.generate(numberOfRows, (index) {
        return Container(
          height: 100, // Высота строки
          margin: EdgeInsets.only(bottom: 10), // Отступ между строками
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(10, (index) {
              return Container(
                width: 100, // Ширина элемента
                height: 100, // Высота элемента
                margin: EdgeInsets.symmetric(horizontal: 8), // Отступ между элементами
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: isCircle
                      ? BorderRadius.circular(100) // Круг для исполнителей
                      : BorderRadius.circular(30), // Закругленные углы для плейлистов и альбомов
                ),
                child: Center(
                  child: Text(
                    isCircle
                      ? 'Исполнитель ${index + 1}' // Текст для кругов (исполнители)
                      : isAlbums
                          ? 'Альбом ${index + 1}' // Текст для альбомов
                          : 'Плейлист ${index + 1}', // Текст для плейлистов
                    style: TextStyle(fontSize: 13), // Уменьшаем размер текста
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