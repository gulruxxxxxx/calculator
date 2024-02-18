import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();
  double _result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controllerA,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '1-son'),
            ),
            TextField(
              controller: _controllerB,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '2-son'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _calculateInIsolate(add),
                  child: Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateInIsolate(subtract),
                  child: Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateInIsolate(multiply),
                  child: Text('*'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateInIsolate(divide),
                  child: Text('/'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _calculateOneNumberInIsolate(square),
                  child: Text('^2'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateOneNumberInIsolate(squareRoot),
                  child: Text('^0.5'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateOneNumberInIsolate(cube),
                  child: Text('^3'),
                ),
                ElevatedButton(
                  onPressed: () => _calculateOneNumberInIsolate(radianToDegrees),
                  child: Text('R/D'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '$_result',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateInIsolate(double Function(double, double) operation) {
    double a = double.tryParse(_controllerA.text) ?? 0;
    double b = double.tryParse(_controllerB.text) ?? 0;
    _calculateOperationInIsolate(operation, a, b);
  }

  void _calculateOneNumberInIsolate(double Function(double) operation) {
    double a = double.tryParse(_controllerA.text) ?? 0;
    _calculateOneNumberOperationInIsolate(operation, a);
  }

  void _calculateOperationInIsolate(double Function(double, double) operation, double a, double b) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_performOperationInIsolate, _IsolateMessage(receivePort.sendPort, operation, a, b));
    receivePort.listen((message) {
      setState(() {
        _result = message;
      });
    });
  }

  void _calculateOneNumberOperationInIsolate(double Function(double) operation, double a) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_performOneNumberOperationInIsolate, _OneNumberIsolateMessage(receivePort.sendPort, operation, a));
    receivePort.listen((message) {
      setState(() {
        _result = message;
      });
    });
  }

  static void _performOperationInIsolate(_IsolateMessage message) {
    double result = message.operation(message.a, message.b);
    message.sendPort.send(result);
  }

  static void _performOneNumberOperationInIsolate(_OneNumberIsolateMessage message) {
    double result = message.operation(message.a);
    message.sendPort.send(result);
  }
}

class _IsolateMessage {
  final SendPort sendPort;
  final double Function(double, double) operation;
  final double a;
  final double b;

  _IsolateMessage(this.sendPort, this.operation, this.a, this.b);
}
class _OneNumberIsolateMessage {
  final SendPort sendPort;
  final double Function(double) operation;
  final double a;

  _OneNumberIsolateMessage(this.sendPort, this.operation, this.a);
}

double add(double a, double b) => a + b;
double subtract(double a, double b) => a - b;
double multiply(double a, double b) => a * b;
double divide(double a, double b) {
  if (b == 0) print("0 ga bo'lib bo'lmaydi");
  return a / b;
}

double square(double a) => a * a;
double cube(double a) => a * a * a;
double squareRoot(double a) {
  if (a < 0) print("manfiy sondan ildiz chiqmaydi");
  return sqrt(a);
}

double radianToDegrees(double radian) => radian * (180 / pi);

