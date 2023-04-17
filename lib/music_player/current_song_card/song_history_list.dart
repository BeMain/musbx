import 'package:flutter/material.dart';
import 'package:musbx/custom_icons.dart';
import 'package:musbx/music_player/music_player.dart';
import 'package:musbx/music_player/song.dart';

class SongHistoryList extends StatefulWidget {
  /// Widget displaying the previously played songs as buttons.
  ///
  /// Pressing a song button tells [MusicPlayer] to load that song.
  const SongHistoryList({super.key});

  @override
  State<StatefulWidget> createState() => SongHistoryListState();
}

class SongHistoryListState extends State<SongHistoryList> {
  final MusicPlayer musicPlayer = MusicPlayer.instance;

  @override
  void initState() {
    musicPlayer.songHistory.addListener(_setState);
    super.initState();
  }

  @override
  void dispose() {
    musicPlayer.songHistory.removeListener(_setState);
    super.dispose();
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: (musicPlayer.songHistory.sorted(ascending: false)
                ..remove(musicPlayer.song))
              .map(_buildSongButton)
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSongButton(Song song) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        onPressed: musicPlayer.isLoading
            ? null
            : () {
                musicPlayer.loadSong(song);
              },
        avatar: _buildSongSourceAvatar(song),
        label: Text(song.title),
      ),
    );
  }

  Widget? _buildSongSourceAvatar(Song song) {
    switch (song.source) {
      case SongSource.file:
        return const Icon(Icons.file_present_rounded);
      case SongSource.youtube:
        return const Icon(CustomIcons.youtube);
      default:
        return null;
    }
  }
}
