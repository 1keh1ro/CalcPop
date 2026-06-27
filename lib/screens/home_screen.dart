import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:calcpops/utils/app_colors.dart';
import 'package:calcpops/models/quiz_models.dart';
import 'package:calcpops/services/question_generator.dart';
import 'package:calcpops/widgets/custom_elevated_button.dart';
import 'package:calcpops/screens/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<Operation> _selectedOps = {Operation.add, Operation.subtract};
  int _questionCount = 10;
  int _maxDigit = 1; // 桁数選択用の状態変数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildSection(context, '演算子を選ぶ', _buildOperationSelector(context)),
              const SizedBox(height: 28),
              _buildSection(context, '問題数', _buildQuestionCountSelector(context)),
              const SizedBox(height: 28),
              _buildSection(context, '桁数を選ぶ', _buildDigitSelector(context)),
              const SizedBox(height: 48),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '計算トレーニング',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '速さと正確さを鍛えよう',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildOperationSelector(BuildContext context) {
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
        return InkWell(
          onTap: () {
            setState(() {
              if (selected && _selectedOps.length > 1) {
                _selectedOps.remove(op);
              } else {
                _selectedOps.add(op);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent.withOpacity(0.15) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.accent : Theme.of(context).cardColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  sym,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: selected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector(BuildContext context) {
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
          return InkWell(
            onTap: () => setState(() => _questionCount = count),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: selected ? AppColors.accentWarm.withOpacity(0.15) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.accentWarm : Theme.of(context).cardColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count問',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: selected ? AppColors.accentWarm : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitSelector(BuildContext context) {
    final digits = [1, 2, 3]; // 1桁、2桁、3桁
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: digits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final digit = digits[i];
          final selected = _maxDigit == digit;
          return InkWell(
            onTap: () => setState(() => _maxDigit = digit),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: selected ? AppColors.accentWarm.withOpacity(0.15) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.accentWarm : Theme.of(context).cardColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$digit桁',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: selected ? AppColors.accentWarm : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return CustomElevatedButton(
      text: 'スタート',
      onPressed: _startQuiz,
    );
  }

  void _startQuiz() {
    final settings = QuizSettings(
      operations: _selectedOps,
      questionCount: _questionCount,
      maxDigit: _maxDigit,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(settings: settings)),
    );
  }
}
