import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  final String urlMusic;
  final String? urlPhoto;
  final String nameSound;
  final String author;
  final Function onBack;

  const PlayerPage({
    super.key,
    required this.urlMusic,
    required this.nameSound,
    required this.author,
    this.urlPhoto,
    required this.onBack,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()
      ..onDurationChanged.listen((duration) {
        setState(() => _duration = duration);
      })
      ..onPositionChanged.listen((position) {
        setState(() => _position = position);
      })
      ..onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setSource(UrlSource(widget.urlMusic));
      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        setState(() => _duration = duration);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка загрузки аудио: $e');
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка воспроизведения: $e');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка перемотки: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _goBack() async {
    widget.onBack();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blueGrey],
          ),
        ),
        child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // Обложка трека
            if (widget.urlPhoto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.urlPhoto!,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.6,
                  errorBuilder: (_, __, ___) => 
                      const Icon(Icons.music_note, size: 100),
                ),
              )
            else
              const Icon(Icons.music_note, size: 100),

            // Информация о треке
            ListTile(
              textColor: Colors.white,
              title: Text(
                widget.nameSound,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 24
                ),
              ),
              subtitle: Text(
                widget.author,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18
                ),
              ),
            ),

            // Прогресс бар
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.clamp(
                  0, 
                  _duration.inSeconds
                ).toDouble(),
                activeColor: Colors.white,
                inactiveColor: Colors.white54,
                onChanged: (value) => _seek(Duration(seconds: value.toInt())),
              ),
            ),

            // Время трека
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _position.format(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    _duration.format(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Управление воспроизведением
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Перемотка назад
                IconButton(
                  icon: const Icon(Icons.fast_rewind, size: 40),
                  color: Colors.white,
                  onPressed: () => _seek(Duration(
                    seconds: (_position.inSeconds - 10)
                      .clamp(0, _duration.inSeconds)
                  ),
                )),
                
                // Play/Pause
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 60,
                  ),
                  color: Colors.white,
                  onPressed: _playPause,
                ),
                
                // Перемотка вперёд
                IconButton(
                  icon: const Icon(Icons.fast_forward, size: 40),
                  color: Colors.white,
                  onPressed: () => _seek(Duration(
                    seconds: (_position.inSeconds + 10)
                      .clamp(0, _duration.inSeconds)
                  )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Кнопка "назад"
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 40),
              color: Colors.white,
              onPressed: _goBack,
            ),
          ),
        ],
      ),
    ),
  );
}}

extension DurationFormatter on Duration {
  String format() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}