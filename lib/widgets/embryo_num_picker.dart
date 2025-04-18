import 'package:flutter/material.dart';

class EmbryoNumberPicker extends StatefulWidget {
  const EmbryoNumberPicker(
      {super.key, required this.onIncrease, required this.onDecrease});

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  State<EmbryoNumberPicker> createState() => _EmbryoNumberPickerState();
}

class _EmbryoNumberPickerState extends State<EmbryoNumberPicker> {
  final _embryoCountController = TextEditingController(text: '1');

  final int minEmbryoCount = 1;
  final int maxEmbryoCount = 16;
  final double _iconSize = 40;
  int prevCount = 1;

  @override
  void dispose() {
    _embryoCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            splashColor: Colors.red.withOpacity(0.3),
            onTap: () {
              int? currEmbryoCount = int.tryParse(_embryoCountController.text);
              if (currEmbryoCount == null) return;

              prevCount = currEmbryoCount;
              currEmbryoCount--;
              _clampAndUpdate(currEmbryoCount, widget.onDecrease);
            },
            child: Ink(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                child: Icon(Icons.remove_rounded,
                    color: Theme.of(context).colorScheme.surface,
                    size: _iconSize))),
        Container(
          color: Theme.of(context).colorScheme.surface,
          constraints: BoxConstraints(maxWidth: 100, maxHeight: _iconSize),
          child: TextField(
              controller: _embryoCountController,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  // constraints: BoxConstraints(maxWidth: 100, maxHeight: 70),
                  border: InputBorder.none),
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
                _handleSubmit(_embryoCountController.text);
              },
              onSubmitted: _handleSubmit),
        ),
        InkWell(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            splashColor: Colors.green.withOpacity(0.3),
            onTap: () {
              int? currEmbryoCount = int.tryParse(_embryoCountController.text);
              if (currEmbryoCount == null) return;

              prevCount = currEmbryoCount;
              currEmbryoCount++;
              _clampAndUpdate(currEmbryoCount, widget.onIncrease);
            },
            child: Ink(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Icon(Icons.add_rounded,
                    color: Theme.of(context).colorScheme.surface,
                    size: _iconSize)))
      ],
    );
  }

  void _clampAndUpdate(int newCount, VoidCallback callback) {
    bool triggerCallback = true;
    if (newCount < minEmbryoCount) {
      newCount = minEmbryoCount;
      triggerCallback = false;
    } else if (newCount > maxEmbryoCount) {
      newCount = maxEmbryoCount;
      triggerCallback = false;
    }

    final String countString = newCount.toString();
    _embryoCountController.value = TextEditingValue(
        text: countString,
        selection: TextSelection.fromPosition(
            TextPosition(offset: countString.length)));

    if (triggerCallback) {
      callback();
    }
  }

  void _handleSubmit(String value) {
    int? embryoCount = int.tryParse(value);
    final String minValue = minEmbryoCount.toString();
    final String maxValue = maxEmbryoCount.toString();

    if (embryoCount == null) {
      _embryoCountController.value = TextEditingValue(
          text: minValue,
          selection: TextSelection.fromPosition(
              TextPosition(offset: minValue.length)));
      embryoCount = minEmbryoCount;
    } else if (embryoCount < minEmbryoCount) {
      _embryoCountController.value = TextEditingValue(
          text: minValue,
          selection: TextSelection.fromPosition(
              TextPosition(offset: minValue.length)));
      embryoCount = minEmbryoCount;
    } else if (embryoCount > maxEmbryoCount) {
      _embryoCountController.value = TextEditingValue(
          text: maxValue,
          selection: TextSelection.fromPosition(
              TextPosition(offset: maxValue.length)));
      embryoCount = maxEmbryoCount;
    }

    int changes = embryoCount - prevCount;
    if (changes > 0) {
      for (int i = 0; i < changes; i++) {
        widget.onIncrease();
      }
    } else if (changes < 0) {
      for (int i = 0; i > -changes; i++) {
        widget.onDecrease();
      }
    }

    prevCount = embryoCount;
  }
}
