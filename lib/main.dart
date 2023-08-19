import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = '';

  Future<void> runIsolateTask() async {
    setState(() {
      result = '';
    });
    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(_heavyFunction, receivePort.sendPort);

    final completer = Completer<void>();

    receivePort.listen((data) {
      setState(() {
        result = data;
      });

      completer.complete();
    });

    await completer.future;
  }

  void runRegularTask() {
    setState(() {
      result = '';
    });
    ReceivePort receivePort = ReceivePort();

    _heavyFunction(receivePort.sendPort); // Pass the sendPort

    receivePort.listen((data) {
      setState(() {
        result = data;
      });
    });
  }

  static void _heavyFunction(SendPort sendPort) {
    // Simulating a heavy CPU task
    int max = 500000000;
    int sum = 0;
    for (int i = 0; i < max; i++) {
      if (kDebugMode) {
        print(sum);
      }
      sum = i;
    }

    if (sendPort != null) {
      sendPort.send('Task Completed. Sum: $sum');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate Demo'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: runIsolateTask,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Run with Isolate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: runRegularTask,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Run without Isolate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            const CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            Container(
              height: 60,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
