import 'package:flutter/material.dart';
import 'package:flutter_advanced/singleton.dart';
import 'package:flutter_advanced/mixin.dart';
import 'package:flutter_advanced/snackbar_mixin.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with LoggingMixin, SnackbarMixin<MyHomePage> {
  final MusicPlayer _musicPlayer = MusicPlayer.instance;

  @override
  void initState() {
    super.initState();
    _musicPlayer.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _musicPlayer.playlist.length,
              itemBuilder: (context, index) {
                final songTitle = _musicPlayer.playlist[index].split('/').last;
                return ListTile(
                  title: Text(songTitle),
                  leading: Icon(
                    _musicPlayer.currentSongIndex == index &&
                            _musicPlayer.playerState == PlayerState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  tileColor: _musicPlayer.currentSongIndex == index
                      ? Colors.black45
                      : null,
                  onTap: () {
                    if (_musicPlayer.currentSongIndex == index &&
                        _musicPlayer.playerState == PlayerState.playing) {
                      _musicPlayer.pause();
                      final message = 'Music paused';
                      log(message);
                      showSnackbar(message);
                    } else {
                      _musicPlayer.play(index);
                      final message = 'Playing $songTitle';
                      log(message);
                      showSnackbar(message);
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30.0,30.0,30.0,100.0),
            child: Column(
              children: <Widget>[
                Text(
                  _musicPlayer.currentSong?.split('/').last ?? 'No song selected',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 48,
                      onPressed: () {
                        _musicPlayer.playPrevious();
                        final message = 'Playing previous song';
                        log(message);
                        showSnackbar(message);
                      },
                    ),
                    IconButton(
                      icon: Icon(_musicPlayer.playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow),
                      iconSize: 64,
                      onPressed: () {
                        if (_musicPlayer.playerState == PlayerState.playing) {
                          _musicPlayer.pause();
                          final message = 'Music paused';
                          log(message);
                          showSnackbar(message);
                        } else {
                          _musicPlayer.play();
                          final message = 'Music playing';
                          log(message);
                          showSnackbar(message);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 48,
                      onPressed: () {
                        _musicPlayer.playNext();
                        final message = 'Playing next song';
                        log(message);
                        showSnackbar(message);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Volume'),
                Slider(
                  value: _musicPlayer.volume,
                  onChanged: (value) {
                    _musicPlayer.setVolume(value);
                    // No snackbar here to avoid spamming
                  },
                  onChangeEnd: (value) {
                    final message = 'Volume changed to ${value.toStringAsFixed(2)}';
                    log(message);
                    showSnackbar(message);
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}