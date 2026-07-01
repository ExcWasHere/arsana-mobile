import 'package:flutter/material.dart';

class SubjectData {
  final String name;
  final String emoji;
  final List<Color> colors;
  final int completed;
  final int total;

  const SubjectData({
    required this.name,
    required this.emoji,
    required this.colors,
    required this.completed,
    required this.total,
  });
}

const List<SubjectData> subjects = [
  SubjectData(
    name: 'Bahasa Isyarat',
    emoji: '👋',
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
    completed: 8,
    total: 12,
  ),
  SubjectData(
    name: 'Matematika',
    emoji: '🔢',
    colors: [Color(0xFFC084FC), Color(0xFF7C3AED)],
    completed: 2,
    total: 10,
  ),
  SubjectData(
    name: 'Bahasa Indonesia',
    emoji: '📖',
    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
    completed: 6,
    total: 10,
  ),
  SubjectData(
    name: 'PPKn',
    emoji: '🏛️',
    colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
    completed: 4,
    total: 8,
  ),
  SubjectData(
    name: 'IPA',
    emoji: '🔬',
    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
    completed: 3,
    total: 8,
  ),
  SubjectData(
    name: 'IPS',
    emoji: '🌍',
    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
    completed: 2,
    total: 6,
  ),
];

enum MateriType { video, interactive, quiz, exam }

extension MateriTypeX on MateriType {
  String get label {
    switch (this) {
      case MateriType.video:
        return 'Video';
      case MateriType.interactive:
        return 'Interaktif';
      case MateriType.quiz:
        return 'Kuis';
      case MateriType.exam:
        return 'Ujian';
    }
  }

  IconData get icon {
    switch (this) {
      case MateriType.video:
        return Icons.play_circle_outline_rounded;
      case MateriType.interactive:
        return Icons.sports_esports_rounded;
      case MateriType.quiz:
        return Icons.description_outlined;
      case MateriType.exam:
        return Icons.emoji_events_outlined;
    }
  }

  Color get color {
    switch (this) {
      case MateriType.video:
        return const Color(0xFF3B82F6);
      case MateriType.interactive:
        return const Color(0xFFA855F7);
      case MateriType.quiz:
        return const Color(0xFF22C55E);
      case MateriType.exam:
        return const Color(0xFFF97316);
    }
  }
}

class MateriListItem {
  final int id;
  final String title;
  final String duration;
  final String description;
  final bool completed;
  final bool locked;
  final MateriType type;

  const MateriListItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.completed,
    required this.locked,
    required this.type,
  });
}

const List<MateriListItem> matematikaMateriList = [
  MateriListItem(
    id: 1,
    title: 'Pengenalan Penjumlahan',
    duration: '15 menit',
    description: 'Belajar konsep dasar penjumlahan dengan cara yang menyenangkan',
    completed: true,
    locked: false,
    type: MateriType.video,
  ),
  MateriListItem(
    id: 2,
    title: 'Penjumlahan 1-10',
    duration: '20 menit',
    description: 'Praktik penjumlahan bilangan 1 sampai 10',
    completed: true,
    locked: false,
    type: MateriType.interactive,
  ),
  MateriListItem(
    id: 3,
    title: 'Penjumlahan 11-20',
    duration: '25 menit',
    description: 'Lanjutan penjumlahan dengan bilangan yang lebih besar',
    completed: false,
    locked: false,
    type: MateriType.video,
  ),
  MateriListItem(
    id: 4,
    title: 'Soal Latihan Penjumlahan',
    duration: '30 menit',
    description: 'Uji kemampuan penjumlahan dengan soal-soal latihan',
    completed: false,
    locked: false,
    type: MateriType.quiz,
  ),
  MateriListItem(
    id: 5,
    title: 'Pengenalan Pengurangan',
    duration: '15 menit',
    description: 'Belajar konsep dasar pengurangan',
    completed: false,
    locked: false,
    type: MateriType.video,
  ),
  MateriListItem(
    id: 6,
    title: 'Pengurangan 1-10',
    duration: '20 menit',
    description: 'Praktik pengurangan bilangan 1 sampai 10',
    completed: false,
    locked: true,
    type: MateriType.interactive,
  ),
  MateriListItem(
    id: 7,
    title: 'Pengurangan 11-20',
    duration: '25 menit',
    description: 'Lanjutan pengurangan dengan bilangan yang lebih besar',
    completed: false,
    locked: true,
    type: MateriType.video,
  ),
  MateriListItem(
    id: 8,
    title: 'Soal Latihan Pengurangan',
    duration: '30 menit',
    description: 'Uji kemampuan pengurangan dengan soal-soal latihan',
    completed: false,
    locked: true,
    type: MateriType.quiz,
  ),
  MateriListItem(
    id: 9,
    title: 'Penjumlahan & Pengurangan',
    duration: '35 menit',
    description: 'Menggabungkan konsep penjumlahan dan pengurangan',
    completed: false,
    locked: true,
    type: MateriType.interactive,
  ),
  MateriListItem(
    id: 10,
    title: 'Ujian Akhir Bab',
    duration: '45 menit',
    description: 'Ujian komprehensif untuk bab penjumlahan dan pengurangan',
    completed: false,
    locked: true,
    type: MateriType.exam,
  ),
];

class MateriDetail {
  final int id;
  final String title;
  final String duration;
  final String videoUrl;
  final List<String> subtopics;

  const MateriDetail({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.subtopics,
  });
}

const List<MateriDetail> perkalianDetailList = [
  MateriDetail(
    id: 1,
    title: 'Pengenalan Perkalian',
    duration: '3:45',
    videoUrl: 'assets/videos/nizam.mp4',
    subtopics: ['Apa itu perkalian?', 'Simbol kali (x)', 'Contoh sederhana'],
  ),
  MateriDetail(
    id: 2,
    title: 'Perkalian 1-5',
    duration: '5:12',
    videoUrl: 'assets/videos/nizam.mp4',
    subtopics: ['Tabel perkalian 1', 'Tabel perkalian 2-5', 'Latihan bersama'],
  ),
  MateriDetail(
    id: 3,
    title: 'Perkalian 6-10',
    duration: '6:30',
    videoUrl: 'assets/videos/nizam.mp4',
    subtopics: ['Tabel perkalian 6-7', 'Tabel perkalian 8-10', 'Trik mudah'],
  ),
  MateriDetail(
    id: 4,
    title: 'Perkalian Dua Angka',
    duration: '8:00',
    videoUrl: 'assets/videos/nizam.mp4',
    subtopics: ['Metode penjumlahan berulang', 'Cara cepat', 'Contoh soal'],
  ),
];

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

const List<QuizQuestion> perkalianQuiz = [
  QuizQuestion(question: '3 x 4 = ?', options: ['10', '12', '14', '7'], answer: 1),
  QuizQuestion(question: '5 x 5 = ?', options: ['20', '30', '25', '15'], answer: 2),
  QuizQuestion(question: '2 x 8 = ?', options: ['16', '18', '14', '10'], answer: 0),
  QuizQuestion(question: '6 x 3 = ?', options: ['15', '21', '18', '24'], answer: 2),
  QuizQuestion(question: '7 x 4 = ?', options: ['28', '24', '21', '32'], answer: 0),
];