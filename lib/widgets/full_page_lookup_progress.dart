import 'package:flutter/material.dart';

class FullPageLookupProgress extends StatelessWidget {
  const FullPageLookupProgress({super.key, required this.progressText});

  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      const Spacer(),
      Expanded(
        flex: 3,
        child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(progressText,
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center),
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 10))
                ])),
      ),
      const Spacer()
    ]);
  }
}
