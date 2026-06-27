enum Operation { add, subtract, multiply, divide }

class Question {
  final int a;
  final int b;
  final Operation op;
  final int answer;

  Question({required this.a, required this.b, required this.op, required this.answer});

  String get operatorSymbol {
    switch (op) {
      case Operation.add: return ‘+’;
      case Operation.subtract: return ‘−’;
      case Operation.multiply: return ‘×’;
      case Operation.divide: return ‘÷’;
    }
  }

  String get expression => ‘$a $operatorSymbol $b’;
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
  final int maxDigit;

  QuizSettings({
    required this.operations,
    required this.questionCount,
    required this.maxDigit,
  });
}
