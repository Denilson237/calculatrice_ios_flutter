import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  final String defaultValue = "0";

  @override
  void initState() {
    super.initState();
    _controller.text = defaultValue;
    initialization();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String lastChar = "";
  List<String> operation = ["AC",'<-',"-/+",'/',"7", "8","9","x","4","5","6","-","1","2","3","+","0",",","="];
  List<String> operation2 = ["+", "/", "x", "-", "-/+", ","];

  String numero = "";

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  calcul() {
    if ((numero == "") || (numero == "error")) {
      return defaultValue;
    }
    numero = numero.replaceAll(",", ".");
    numero = numero.replaceAll("x", "*");
    try {
      final parser = Parser();
      final expression = parser.parse(numero);
      final context = ContextModel();
      final result = expression.evaluate(EvaluationType.REAL, context);
      String resultat = toInt(result)?.toString() ?? defaultValue;
      return resultat;
    } catch (e) {
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    double largeur = (MediaQuery.of(context).size.width/4.4)-6;
    int util = _controller.text.length;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white, brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Created by Denilson",
            style: TextStyle(
                color: Colors.white60,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body:  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                       bottom: 25.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.15,
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: util  > 8 ? 35 : util  > 11 ? 18: 50,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                        labelText: '',
                      ),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.none,
                      maxLength: 13,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) {
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30.0),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: <Widget>[
                      for (int index = 0; index < 19; index++)
                        boutons(
                          operation[index],
                          Colors.grey[600]!,largeur,
                          isWide: index == 18,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

 Widget boutons(
    String text,
    Color color,
    double largeur, {
    double x = 0.0,
    double y = 0.0,
    Color colors = Colors.white,
    bool isWide = false,
  }) {
    return SizedBox(
      width: isWide ? largeur * 2 + 6 : largeur,
      height: largeur,
      child: InkWell(
        onTap: () {
          setState(() {
            if ((_controller.text.length < 15) &&
                (text != "AC") &&
                (text != "-/+") &&
                (text != "=") &&
                (text != '<-')) {
              if (!(operation2.contains(lastChar)) ||
                  !(operation2.contains(text))) {
                numero += text;
                lastChar = text;
                if ((operation2.contains(numero[0]) &&
                    numero[0] != "-" &&
                    numero[0] != "+") || (numero[0] == "0" && numero.length == 1)) {
                  _controller.text = defaultValue;
                  numero = "";
                  lastChar = "";
                } else {
                  _controller.text = double.tryParse(numero) != null
                      ? NumberFormat('#,###.##').format(double.parse(numero))
                      : numero;
                }
              }
            } else if (text == "AC") {
              _controller.clear();
              numero = "";
              lastChar = "";
              _controller.text = defaultValue;
            } else if (text == "=") {
              numero = calcul();
              _controller.text = double.tryParse(numero) != null
                  ? NumberFormat('#,###.########').format(double.parse(numero))
                  : numero;

              lastChar = "";
              if ((numero == '0') || (numero == "error")) {
                numero = "";
              }
            } else if (text == '<-') {
              _controller.text = numero = numero.isNotEmpty
                  ? numero.substring(0, numero.length - 1)
                  : '0';
                  lastChar = "";
              if ((numero == "error") ||
                  (numero == '0') | (numero == '')) {
                _controller.text = defaultValue;
                numero = "";
              }
            } else if (text == "-/+") {
              _controller.text = numero = negatif();
              if (numero == "error") {
                numero = "";
              }
            }
          });
        },
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                      color: colors, fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(width: x, height: y),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double roundTo(double value, int decimals) {
    num mod = pow(10.0, decimals.toDouble());
    return ((value * mod).round().toDouble() / mod);
  }

  toInt(value) {
    if (value % 1 == 0) {
      return value.toInt();
    } else {
      return roundTo(value, 8);
    }
  }

  String negatif() {
    if (numero == "") {
      numero = '0';
    }
    try {
      List<String> parts = numero.split("-/+");
      double operand1 = double.parse(parts[0]);
      operand1 = -1 * operand1;
      String result = toInt(operand1).toString();
      return result;
    } catch (e) {
      return "error";
    }
  }
}