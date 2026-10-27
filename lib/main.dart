import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MusicAdvance());
}

class MusicAdvance extends StatelessWidget {
  const MusicAdvance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Advance',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090711),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B5CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const MusicHome(),
    );
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer player = AudioPlayer();
  final List<PlatformFile> songs = [];
  int current = -1;

  Future<void> addSongs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        songs.addAll(result.files.where((f) => f.path != null));
      });
    }
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= songs.length) return;
    final path = songs[index].path;
    if (path == null) return;

    try {
      await player.setFilePath(path);
      await player.play();
      setState(() => current = index);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível tocar esta música.')),
        );
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playingSong =
        current >= 0 && current < songs.length ? songs[current].name : 'Nenhuma música';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090711),
        title: const Text(
          'MUSIC ADVANCE',
          style: TextStyle(
            color: Color(0xFFB889FF),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: addSongs,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Adicionar músicas',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5424A8), Color(0xFF171126)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.graphic_eq, size: 42, color: Color(0xFFD5B8FF)),
                    SizedBox(height: 18),
                    Text(
                      'SUA MÚSICA.',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Seu som, do seu jeito.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'MINHAS MÚSICAS',
                style: TextStyle(
                  color: Color(0xFFB889FF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: songs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.library_music_outlined,
                              size: 64,
                              color: Color(0xFF7755A8),
                            ),
                            const SizedBox(height: 12),
                            const Text('Sua biblioteca está vazia'),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: addSongs,
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar músicas'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final selected = index == current;

                          return Card(
                            color: selected
                                ? const Color(0xFF35204F)
                                : const Color(0xFF171420),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5424A8),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.music_note),
                              ),
                              title: Text(
                                song.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(selected ? 'Selecionada' : 'Arquivo local'),
                              trailing: IconButton(
                                icon: Icon(
                                  selected ? Icons.graphic_eq : Icons.play_arrow,
                                  color: const Color(0xFFB889FF),
                                ),
                                onPressed: () => playSong(index),
                              ),
                              onTap: () => playSong(index),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1528),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.album, size: 42, color: Color(0xFFB889FF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        playingSong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;
                        return IconButton(
                          iconSize: 34,
                          color: const Color(0xFFB889FF),
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                          ),
                          onPressed: () async {
                            if (isPlaying) {
                              await player.pause();
                            } else if (current >= 0) {
                              await player.play();
                            } else if (songs.isNotEmpty) {
                              await playSong(0);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
