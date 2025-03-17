import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NurseryPage extends StatefulWidget {
  const NurseryPage({super.key});

  @override
  State<NurseryPage> createState() => _NurseryPageState();
}

class _NurseryPageState extends State<NurseryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NUrsery'),
      ),
    );
  }
}
