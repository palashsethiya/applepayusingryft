import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel methodChannel = MethodChannel('ryftPaymentGatewayInitiate');

  Future<void> _getRyftPaymentGateway(String paymentMethodType) async {
    try {
      final String? result = await methodChannel.invokeMethod('initiatePayment', {
        "publishableKey": "pk_sandbox_aP+byzuOJnUjJnVow1n07IVexKDmRITGdwCU/EICJ9eyHTz87k/tdQNkZvw7SL4q",
        "clientSecret": "ps_01J3HVDR8J3GY0A8MA1FHRPP3W_secret_8f4f1e9b-810d-47b6-9fba-760cea1c9858",
        "subAccountId": "ac_604213b8-2998-4d0a-94bc-23266feb7274",
        "paymentMethodType": paymentMethodType, // dropIn, applePay
      });

      if (kDebugMode) {
        print("Flutter result $result");
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Error Platform $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Apple Pay"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _getRyftPaymentGateway("dropIn");
            },
            child: const Text('Pay Using DropIn'),
          ),
          ElevatedButton(
            onPressed: () {
              _getRyftPaymentGateway("applePay");
            },
            child: const Text('Pay Using Apple Pay'),
          ),
        ],
      )),
    );
  }
}
