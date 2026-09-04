import 'package:flutter/material.dart';

class LoadingErrorWidget extends StatelessWidget {
  const LoadingErrorWidget({
    super.key,
    required this.errorText,
    required this.buttonText,
    required this.callback,
  });

  final String errorText;
  final String buttonText;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                errorText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(onPressed: callback, child: Text(buttonText)),
            ],
          ),
        ),
      ),
    );
  }
}
