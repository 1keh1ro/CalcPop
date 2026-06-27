import 'package:flutter/material.dart';
import 'package:calcpops/utils/app_colors.dart';
import 'package:calcpops/models/quiz_models.dart';
import 'package:calcpops/widgets/custom_elevated_button.dart';

class ResultScreen extends StatelessWidget {
  final List<QuizResult> results;
  final int totalTimeSeconds;
  final QuizSettings settings;

  const ResultScreen({
    super.key,
    required this.results,
    required this.totalTimeSeconds,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswers = results.where((r) => r.isCorrect).length;
    final accuracy = (correctAnswers / results.length * 100).toStringAsFixed(1);
    final averageTimeMs = results.map((r) => r.timeTakenMs).reduce((a, b) => a + b) / results.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAccuracyRing(context, double.parse(accuracy)),
                    const SizedBox(height: 32),
                    _buildStatsRow(context, correctAnswers, totalTimeSeconds, averageTimeMs),
                    const SizedBox(height: 32),
                    _buildDetailList(context),
                  ],
                ),
              ),
            ),
            _buildRetryButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '結果',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }

  Widget _buildAccuracyRing(BuildContext context, double accuracy) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: accuracy / 100,
              strokeWidth: 12,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                accuracy >= 80 ? AppColors.success : (accuracy >= 50 ? AppColors.accentWarm : AppColors.error),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${accuracy.toInt()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                '正答率',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int correctAnswers, int totalTimeSeconds, double averageTimeMs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(context, '正解数', '$correctAnswers問', AppColors.success),
        _buildStatCard(context, '合計時間', '${totalTimeSeconds}秒', AppColors.primary),
        _buildStatCard(context, '平均解答時間', '${averageTimeMs.toStringAsFixed(1)}ms', AppColors.accentWarm),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Card(
      color: AppColors.surface,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width / 3 - 32, // 画面幅に応じて調整
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '問題ごとの詳細',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${result.question.expression} = ${result.question.answer}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Row(
                      children: [
                        Icon(
                          result.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: result.isCorrect ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result.isCorrect ? '正解' : '不正解',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: result.isCorrect ? AppColors.success : AppColors.error,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${result.timeTakenMs}ms',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CustomElevatedButton(
        text: 'もう一度',
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttonTextDark,
      ),
    );
  }
}
