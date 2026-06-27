import 'dart:math';
import 'package:calcpops/models/quiz_models.dart';

class QuestionGenerator {
  static final Random _random = Random();

  static Question generate(Set<Operation> operations, int maxDigit) {
    final difficulty = maxDigit; // 桁数を難易度として利用
    final maxNum = pow(10, maxDigit).toInt() - 1; // 最大値
    final minNum = pow(10, maxDigit - 1).toInt(); // 最小値
    final op = operations.elementAt(_random.nextInt(operations.length));
    int a, b, answer;

    switch (op) {
      case Operation.add:
        a = _random.nextInt(maxNum - minNum + 1) + minNum;
        b = _random.nextInt(maxNum - minNum + 1) + minNum;
        answer = a + b;
        break;
      case Operation.subtract:
        a = _random.nextInt(maxNum - minNum + 1) + minNum;
        b = _random.nextInt(a - minNum + 1) + minNum; // bはaより小さく、かつminNum以上
        answer = a - b;
        break;
      case Operation.multiply:
        a = _random.nextInt(maxNum ~/ 2) + 2; // 掛け算の数を調整
        b = _random.nextInt(maxNum ~/ 2) + 2;
        answer = a * b;
        break;
      case Operation.divide:
        b = _random.nextInt(maxNum ~/ 2) + 2; // 割る数を調整
        answer = _random.nextInt(maxNum ~/ b) + 1; // 答えを調整
        a = b * answer;
        break;
    }

    return Question(a: a, b: b, op: op, answer: answer);
  }
}
