import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MathQuizApp());
}

class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '計算トレーニング',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5CC),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}


enum Operation { add, subtract, multiply, divide }

class Question {
  final int a;
  final int b;
  final Operation op;
  final int answer;

  Question({required this.a, required this.b, required this.op, required this.answer});

  String get operatorSymbol {
    switch (op) {
      case Operation.add: return '+';
      case Operation.subtract: return '−';
      case Operation.multiply: return '×';
      case Operation.divide: return '÷';
    }
  }

  String get expression => '$a $operatorSymbol $b';
}

class QuizResult {
  final Question question;
  final int? userAnswer;
  final int timeTakenMs;
  final bool isCorrect;

  QuizResult({
    required this.question,
    required this.userAnswer,
    required this.timeTakenMs,
    required this.isCorrect,
  });
}

class QuizSettings {
  final Set<Operation> operations;
  final int questionCount;

  QuizSettings({
    required this.operations,
    required this.questionCount,
  });
}


class QuestionGenerator {
  static final Random _random = Random();

  static Question generate(Set<Operation> operations, {int difficulty = 1}) {
    final op = operations.elementAt(_random.nextInt(operations.length));
    int a, b, answer;

    switch (op) {
      case Operation.add:
        a = _random.nextInt(50 * difficulty) + 1;
        b = _random.nextInt(50 * difficulty) + 1;
        answer = a + b;
        break;
      case Operation.subtract:
        a = _random.nextInt(50 * difficulty) + 10;
        b = _random.nextInt(a) + 1;
        answer = a - b;
        break;
      case Operation.multiply:
        a = _random.nextInt(9 * difficulty) + 2;
        b = _random.nextInt(9 * difficulty) + 2;
        answer = a * b;
        break;
      case Operation.divide:
        b = _random.nextInt(9) + 2;
        answer = _random.nextInt(12) + 1;
        a = b * answer;
        break;
    }

    return Question(a: a, b: b, op: op, answer: answer);
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<Operation> _selectedOps = {Operation.add, Operation.subtract};
  int _questionCount = 10;

  static const Color _bg = Color(0xFF0D1B2A);
  static const Color _surface = Color(0xFF1A2D42);
  static const Color _accent = Color(0xFF00E5CC);
  static const Color _accentWarm = Color(0xFFFFB347);
  static const Color _textPrimary = Color(0xFFECF0F1);
  static const Color _textSecondary = Color(0xFF8FA4B2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildSection('演算子を選ぶ', _buildOperationSelector()),
              const SizedBox(height: 28),
              _buildSection('問題数', _buildQuestionCountSelector()),
              const SizedBox(height: 48),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '計算トレーニング',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          '速さと正確さを鍛えよう',
          style: TextStyle(fontSize: 14, color: _textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildOperationSelector() {
    final ops = [
      (Operation.add, '+', '足し算'),
      (Operation.subtract, '−', '引き算'),
      (Operation.multiply, '×', '掛け算'),
      (Operation.divide, '÷', '割り算'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ops.map((item) {
        final (op, sym, label) = item;
        final selected = _selectedOps.contains(op);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected && _selectedOps.length > 1) {
                _selectedOps.remove(op);
              } else {
                _selectedOps.add(op);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? _accent.withOpacity(0.15) : _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _accent : _surface,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  sym,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: selected ? _accent : _textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? _accent : _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    final counts = [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100];
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: counts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final count = counts[i];
          final selected = _questionCount == count;
          return GestureDetector(
            onTap: () => setState(() => _questionCount = count),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: selected ? _accentWarm.withOpacity(0.15) : _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _accentWarm : _surface,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count問',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? _accentWarm : _textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startQuiz,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5CC), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'スタート',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    final settings = QuizSettings(
      operations: _selectedOps,
      questionCount: _questionCount,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(settings: settings)),
    );
  }
}


class QuizScreen extends StatefulWidget {
  final QuizSettings settings;
  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF0D1B2A);
  static const Color _surface = Color(0xFF1A2D42);
  static const Color _accent = Color(0xFF00E5CC);
  static const Color _textPrimary = Color(0xFFECF0F1);
  static const Color _textSecondary = Color(0xFF8FA4B2);
  static const Color _correct = Color(0xFF2ECC71);
  static const Color _incorrect = Color(0xFFE74C3C);

  late List<Question> _questions;
  int _currentIndex = 0;
  final List<QuizResult> _results = [];
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 問題ごとのタイマー
  late Stopwatch _questionStopwatch;
  // 全体経過時間表示用
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  // フィードバックアニメーション
  late AnimationController _feedbackController;
  late Animation<double> _feedbackOpacity;
  bool _lastAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _questions = List.generate(
      widget.settings.questionCount,
      (_) => QuestionGenerator.generate(widget.settings.operations),
    );
    _questionStopwatch = Stopwatch()..start();

    // 全体経過時間を1秒ごとに更新
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _elapsedTimer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return m > 0 ? '$m分${s.toString().padLeft(2, '0')}秒' : '$s秒';
  }

  void _submitAnswer() {
    final input = _answerController.text.trim();
    if (input.isEmpty) return;
    final userAnswer = int.tryParse(input);
    final q = _questions[_currentIndex];
    final isCorrect = userAnswer == q.answer;
    final timeTaken = _questionStopwatch.elapsedMilliseconds;

    _results.add(QuizResult(
      question: q,
      userAnswer: userAnswer,
      timeTakenMs: timeTaken,
      isCorrect: isCorrect,
    ));

    setState(() {
      _lastAnswerCorrect = isCorrect;
    });
    _feedbackController.forward(from: 0);

    _answerController.clear();
    _questionStopwatch.reset();

    if (_currentIndex + 1 >= _questions.length) {
      Future.delayed(const Duration(milliseconds: 400), _finishQuiz);
    } else {
      setState(() => _currentIndex++);
      _focusNode.requestFocus();
    }
  }

  void _finishQuiz() {
    _elapsedTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(results: _results, totalSeconds: _elapsedSeconds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(progress),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuestionCard(q),
                    const SizedBox(height: 40),
                    _buildAnswerInput(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: _textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _surface,
                valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 経過時間表示
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: _textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(
                _elapsedFormatted,
                style: const TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question q) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _accent.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Text(
                q.expression,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '= ?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: _accent,
                ),
              ),
            ],
          ),
        ),
        FadeTransition(
          opacity: _feedbackOpacity,
          child: IgnorePointer(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: (_lastAnswerCorrect ? _correct : _incorrect).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(
                _lastAnswerCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerInput() {
    return TextField(
      controller: _answerController,
      focusNode: _focusNode,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '答えを入力',
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 20),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onSubmitted: (_) => _submitAnswer(),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitAnswer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5CC), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          '回答する',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ==================== 結果画面 ====================

class ResultScreen extends StatelessWidget {
  final List<QuizResult> results;
  final int totalSeconds;

  static const Color _bg = Color(0xFF0D1B2A);
  static const Color _surface = Color(0xFF1A2D42);
  static const Color _accent = Color(0xFF00E5CC);
  static const Color _accentWarm = Color(0xFFFFB347);
  static const Color _textPrimary = Color(0xFFECF0F1);
  static const Color _textSecondary = Color(0xFF8FA4B2);
  static const Color _correct = Color(0xFF2ECC71);
  static const Color _incorrect = Color(0xFFE74C3C);

  const ResultScreen({super.key, required this.results, required this.totalSeconds});

  int get correctCount => results.where((r) => r.isCorrect).length;
  double get accuracy => results.isEmpty ? 0 : correctCount / results.length * 100;
  double get avgTimeSec =>
      results.isEmpty ? 0 : results.map((r) => r.timeTakenMs).reduce((a, b) => a + b) / results.length / 1000;
  int get fastestMs => results.isEmpty ? 0 : results.map((r) => r.timeTakenMs).reduce(min);
  int get slowestMs => results.isEmpty ? 0 : results.map((r) => r.timeTakenMs).reduce(max);

  String get totalTimeFormatted {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return m > 0 ? '$m分${s.toString().padLeft(2, '0')}秒' : '$s秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    _buildAccuracyRing(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildDetailList(),
                    const SizedBox(height: 32),
                    _buildRetryButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Icon(Icons.home_outlined, color: _textSecondary),
          ),
          const Spacer(),
          const Text(
            '結果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildAccuracyRing() {
    final grade = accuracy >= 90
        ? ('S', _accent)
        : accuracy >= 70
            ? ('A', _correct)
            : accuracy >= 50
                ? ('B', _accentWarm)
                : ('C', _incorrect);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: 10,
                  backgroundColor: _bg,
                  valueColor: AlwaysStoppedAnimation<Color>(grade.$2),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    grade.$1,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: grade.$2,
                    ),
                  ),
                  Text(
                    '${accuracy.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$correctCount / ${results.length} 問正解',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('合計時間', totalTimeFormatted, Icons.timer_outlined),
        const SizedBox(width: 12),
        _buildStatCard('平均タイム', '${avgTimeSec.toStringAsFixed(2)}秒', Icons.speed),
        const SizedBox(width: 12),
        _buildStatCard('最速', '${(fastestMs / 1000).toStringAsFixed(2)}秒', Icons.bolt),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: _accent, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: _textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text('問題', style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                Spacer(),
                Text('あなたの答え', style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(width: 24),
                Text('時間', style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF243447), height: 1),
          ...results.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        r.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: r.isCorrect ? _correct : _incorrect,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${i + 1}. ${r.question.expression} = ${r.question.answer}',
                        style: const TextStyle(color: _textPrimary, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        r.userAnswer != null ? '${r.userAnswer}' : '—',
                        style: TextStyle(
                          color: r.isCorrect ? _correct : _incorrect,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '${(r.timeTakenMs / 1000).toStringAsFixed(1)}s',
                        style: const TextStyle(color: _textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (i < results.length - 1)
                  const Divider(color: Color(0xFF243447), height: 1, indent: 44),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5CC), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'もう一度',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}