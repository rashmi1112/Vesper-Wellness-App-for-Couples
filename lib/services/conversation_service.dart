import 'dart:math';
import 'package:flutter/foundation.dart';

class ConversationPrompt {
  final String question;
  final String category;
  final String emoji;

  const ConversationPrompt({
    required this.question,
    required this.category,
    required this.emoji,
  });
}

class ConversationService extends ChangeNotifier {
  final List<ConversationPrompt> _prompts = const [
    // Deep Connection
    ConversationPrompt(
      question: 'What is one thing you wish I understood better about you?',
      category: 'Deep Connection',
      emoji: '💭',
    ),
    ConversationPrompt(
      question: 'What moment in our relationship are you most grateful for?',
      category: 'Deep Connection',
      emoji: '🙏',
    ),
    ConversationPrompt(
      question: 'If you could relive any day we spent together, which would it be?',
      category: 'Deep Connection',
      emoji: '✨',
    ),
    ConversationPrompt(
      question: 'What do you think is our greatest strength as a couple?',
      category: 'Deep Connection',
      emoji: '💪',
    ),
    ConversationPrompt(
      question: 'How have I helped you grow as a person?',
      category: 'Deep Connection',
      emoji: '🌱',
    ),
    
    // Dreams & Goals
    ConversationPrompt(
      question: 'Where do you see us in five years?',
      category: 'Dreams & Goals',
      emoji: '🔮',
    ),
    ConversationPrompt(
      question: 'What is one adventure you want us to experience together?',
      category: 'Dreams & Goals',
      emoji: '🗺️',
    ),
    ConversationPrompt(
      question: 'What is a skill you would love for us to learn together?',
      category: 'Dreams & Goals',
      emoji: '📚',
    ),
    ConversationPrompt(
      question: 'If we could live anywhere in the world for a year, where would you choose?',
      category: 'Dreams & Goals',
      emoji: '🌍',
    ),
    ConversationPrompt(
      question: 'What is one goal you have been afraid to share with me?',
      category: 'Dreams & Goals',
      emoji: '💫',
    ),
    
    // Love Languages
    ConversationPrompt(
      question: 'When do you feel most loved by me?',
      category: 'Love Languages',
      emoji: '❤️',
    ),
    ConversationPrompt(
      question: 'What small gesture from me means the most to you?',
      category: 'Love Languages',
      emoji: '🎁',
    ),
    ConversationPrompt(
      question: 'How can I better support you when you are stressed?',
      category: 'Love Languages',
      emoji: '🤗',
    ),
    ConversationPrompt(
      question: 'What is your favorite way to spend quality time with me?',
      category: 'Love Languages',
      emoji: '⏰',
    ),
    ConversationPrompt(
      question: 'What words of encouragement do you need to hear more often?',
      category: 'Love Languages',
      emoji: '💬',
    ),
    
    // Fun & Playful
    ConversationPrompt(
      question: 'If we were characters in a movie, what genre would our love story be?',
      category: 'Fun & Playful',
      emoji: '🎬',
    ),
    ConversationPrompt(
      question: 'What is the silliest thing you love about me?',
      category: 'Fun & Playful',
      emoji: '😂',
    ),
    ConversationPrompt(
      question: 'If we could have any superpower as a couple, what would it be?',
      category: 'Fun & Playful',
      emoji: '🦸',
    ),
    ConversationPrompt(
      question: 'What song reminds you most of us?',
      category: 'Fun & Playful',
      emoji: '🎵',
    ),
    ConversationPrompt(
      question: 'If we had a reality TV show, what would it be called?',
      category: 'Fun & Playful',
      emoji: '📺',
    ),
    
    // Memories
    ConversationPrompt(
      question: 'What was your first impression of me?',
      category: 'Memories',
      emoji: '👀',
    ),
    ConversationPrompt(
      question: 'When did you first know you loved me?',
      category: 'Memories',
      emoji: '💕',
    ),
    ConversationPrompt(
      question: 'What is your favorite inside joke we share?',
      category: 'Memories',
      emoji: '🤭',
    ),
    ConversationPrompt(
      question: 'What is the most meaningful gift I have ever given you?',
      category: 'Memories',
      emoji: '🎀',
    ),
    ConversationPrompt(
      question: 'What is a challenge we overcame that made us stronger?',
      category: 'Memories',
      emoji: '🏔️',
    ),
  ];

  List<String> get categories => _prompts.map((p) => p.category).toSet().toList();

  List<ConversationPrompt> get allPrompts => List.unmodifiable(_prompts);

  List<ConversationPrompt> getPromptsByCategory(String category) =>
      _prompts.where((p) => p.category == category).toList();

  ConversationPrompt getRandomPrompt([String? category]) {
    final prompts = category != null ? getPromptsByCategory(category) : _prompts;
    return prompts[Random().nextInt(prompts.length)];
  }

  ConversationPrompt get dailyPrompt {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _prompts[dayOfYear % _prompts.length];
  }
}
