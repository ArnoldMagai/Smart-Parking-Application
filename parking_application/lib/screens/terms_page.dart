import 'package:flutter/material.dart';

class TermsPage
    extends StatelessWidget {

  const TermsPage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
                "Privacy Policy"),
      ),

      body: const Padding(

        padding:
            EdgeInsets.all(16),

        child: Text(
          "Smart Parking collects location and parking information only to improve parking services.",
        ),
      ),
    );
  }
}