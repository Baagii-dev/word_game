import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import 'battle_screen.dart';

/// Ялалт / ялагдлын дэлгэц. Нээгдэх үедээ үр дүнг хадгална.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.level,
    required this.won,
    required this.score,
    required this.stars,
    required this.wordsCount,
    required this.longestWord,
  });

  final Level level;
  final bool won;
  final int score;
  final int stars;
  final int wordsCount;
  final String longestWord;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Дэлгэц зурагдаж дууссаны дараа хадгална
    // (build хийгдэж байх үед өөр дэлгэцийг шинэчлэхээс сэргийлнэ)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StorageService.instance.saveResult(
        levelId: widget.level.id,
        score: widget.score,
        stars: widget.stars,
      );
    });
  }

  Level? get _nextLevel {
    for (final l in kLevels) {
      if (l.id == widget.level.id + 1) return l;
    }
    return null;
  }

  void _play(Level level) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BattleScreen(level: level)),
    );
  }

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final next = _nextLevel;

    return Scaffold(
      backgroundColor: widget.won ? AppColors.grass : AppColors.woodDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.won ? '🏆' : '💀',
                      style: const TextStyle(fontSize: 64),
                    ),
                    Text(
                      widget.won ? 'Ялалт!' : 'Ялагдал',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.won)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < widget.stars ? Icons.star : Icons.star_border,
                            color: AppColors.accent,
                            size: 40,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _statRow('Оноо', '${widget.score}'),
                    _statRow('Бүтээсэн үг', '${widget.wordsCount}'),
                    _statRow(
                      'Хамгийн урт үг',
                      widget.longestWord.isEmpty
                          ? '-'
                          : widget.longestWord.toUpperCase(),
                    ),
                    const SizedBox(height: 24),
                    if (widget.won && next != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _play(next),
                          child: const Text('Дараагийн түвшин'),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _play(widget.level),
                        child: const Text('Дахин тоглох'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Түвшин сонгох'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
