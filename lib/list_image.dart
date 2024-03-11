import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("images/messi.jpg"),
        Image.asset("images/casilas.jpg"),
        Image.asset("images/messi.jpg"),
        Image.asset("images/dropba.jpg"),
        Image.asset("images/iniesta.jpg"),
        Image.asset("images/maradona.jpg"),
        Image.asset("images/pele.jpg"),
        Image.asset("images/ronaldo.jpg"),
      ],
    );
  }
}
