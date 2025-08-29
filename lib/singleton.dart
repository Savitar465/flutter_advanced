import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayer extends ChangeNotifier {
  MusicPlayer._internal();

  static final MusicPlayer _instance = MusicPlayer._internal();

  static MusicPlayer get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  double _volume = 1.0;
  int _currentSongIndex = -1;

  final List<String> _playlist = [
    'https://sampleswap.org/mp3/artist/5101/Peppy--The-Firing-Squad_YMXB-160.mp3',
    'https://sampleswap.org/mp3/artist/30220/alienzzz_maniac-in-the-desert-160.mp3',
    'https://sampleswap.org/mp3/artist/2/canton_reaktion-160.mp3',
  ];

  PlayerState get playerState => _playerState;
  double get volume => _volume;
  List<String> get playlist => _playlist;
  int get currentSongIndex => _currentSongIndex;
  String? get currentSong =>
      _currentSongIndex != -1 ? _playlist[_currentSongIndex] : null;

  MusicPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNext();
    });
  }

  Future<void> play([int? index]) async {
    if (index != null) {
      _currentSongIndex = index;
    }
    if (_currentSongIndex == -1) {
      _currentSongIndex = 0;
    }
    await _audioPlayer.play(UrlSource(_playlist[_currentSongIndex]));
    _playerState = PlayerState.playing;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.stopped;
    _currentSongIndex = -1;
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentSongIndex < _playlist.length - 1) {
      _currentSongIndex++;
      await play(_currentSongIndex);
    } else {
      stop();
    }
    notifyListeners();
  }

  Future<void> playPrevious() async {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      await play(_currentSongIndex);
    }
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }
}