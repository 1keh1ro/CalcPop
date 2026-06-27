import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:calcpops/utils/app_colors.dart';
import 'package:calcpops/models/quiz_models.dart';
import 'package:calcpops/services/question_generator.dart';
import 'package:calcpops/widgets/custom_elevated_button.dart';
import 'package:calcpops/screens/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizSettings settings;
  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
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

  // カウントダウン用
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _isCountingDown = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
    );
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          _initializeQuiz();
        });
      }
    });
  }

  void _initializeQuiz() {
    _questions = List.generate(
      widget.settings.questionCount,
      (_) => QuestionGenerator.generate(widget.settings.operations, widget.settings.maxDigit),
    );
    _questionStopwatch = Stopwatch()..start();

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _elapsedTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleKeypadTap(String value) {
    HapticFeedback.lightImpact(); // 触覚フィードバック
    setState(() {
      if (value == 'DEL') {
        if (_answerController.text.isNotEmpty) {
          _answerController.text = _answerController.text.substring(0, _answerController.text.length - 1);
        }
      } else if (value == 'AC') {
        _answerController.clear();
      } else if (value == '=') {
        _submitAnswer();
      } else {
        _answerController.text += value;
      }
    });
  }

  void _submitAnswer() {
    if (_answerController.text.isEmpty) return;

    _questionStopwatch.stop();
    final currentQuestion = _questions[_currentIndex];
    final userAnswer = int.tryParse(_answerController.text);
    final isCorrect = userAnswer == currentQuestion.answer;

    _results.add(QuizResult(
      question: currentQuestion,
      userAnswer: userAnswer,
      timeTakenMs: _questionStopwatch.elapsedMilliseconds,
      isCorrect: isCorrect,
    ));

    setState(() {
      _lastAnswerCorrect = isCorrect;
      _feedbackController.forward(from: 0.0);
    });

    _answerController.clear();
    _questionStopwatch.reset();

    if (_currentIndex < widget.settings.questionCount - 1) {
      _questionStopwatch.start();
      setState(() {
        _currentIndex++;
      });
    } else {
      _elapsedTimer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            results: _results,
            totalTimeSeconds: _elapsedSeconds,
            settings: widget.settings,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isCountingDown
            ? _buildCountdownScreen(context)
            : Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuestionCard(context),
                        const SizedBox(height: 20),
                        _buildAnswerInput(context),
                        const SizedBox(height: 20),
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                  _buildKeypad(context),
                ],
              ),
      ),
    );
  }

  Widget _buildCountdownScreen(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _feedbackController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (1.0 - _feedbackOpacity.value) * 0.5, // カウントダウンの拡大アニメーション
            child: Opacity(
              opacity: _feedbackOpacity.value, // フェードアウトアニメーション
              child: Text(
                _countdown == 0 ? 'スタート！' : _countdown.toString(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      color: AppColors.accent,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
            ),
          ),
          Text(
            '${_currentIndex + 1} / ${widget.settings.questionCount}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '${_elapsedSeconds}秒',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              currentQuestion.expression,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            AnimatedBuilder(
              animation: _feedbackController,
              builder: (context, child) {
                return Opacity(
                  opacity: _feedbackOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - _feedbackOpacity.value) * -20), // 上に移動
                    child: Text(
                      _lastAnswerCorrect ? '正解！' : '不正解！',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: _lastAnswerCorrect ? AppColors.success : AppColors.error,
                            fontSize: 28,
                          ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _answerController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.none, // カスタムキーパッドを使用するため、システムキーボードを無効化
        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 36),
        decoration: InputDecoration(
          hintText: '答えを入力',
          hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 36, color: AppColors.textSecondary.withOpacity(0.5)),
        ),
        readOnly: true, // カスタムキーパッドからの入力のみを受け付ける
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return CustomElevatedButton(
      text: '回答',
      onPressed: _submitAnswer,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.buttonTextDark,
    );
  }

  Widget _buildKeypad(BuildContext context) {
    final List<List<String>> keys = [
      ['1', '2', '3', 'DEL'],
      ['4', '5', '6', 'AC'],
      ['7', '8', '9', '='],
      ['00', '0', '.'], // 小数点対応のため追加
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.keypadBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildKeypadButton(context, key),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, String key) {
    Color buttonColor = AppColors.keypadButtonBackground;
    Color textColor = AppColors.keypadButtonText;
    Function()? onPressed = () => _handleKeypadTap(key);

    if (key == 'DEL') {
      buttonColor = AppColors.keypadFunctionButtonBackground;
      textColor = AppColors.keypadFunctionButtonText;
    } else if (key == 'AC') {
      buttonColor = AppColors.keypadFunctionButtonBackground;
      textColor = AppColors.keypadFunctionButtonText;
    } else if (key == '=') {
      buttonColor = AppColors.accent;
      textColor = AppColors.buttonTextDark;
    } else if (key == '.') {
      onPressed = null; // 小数点入力は今回は無効
      buttonColor = AppColors.keypadButtonBackground.withOpacity(0.5);
      textColor = AppColors.keypadButtonText.withOpacity(0.5);
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          key,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: textColor,
                fontSize: 32,
              ),
        ),
      ),
    );
  }
}
