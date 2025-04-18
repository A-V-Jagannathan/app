import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/embryo_model.dart';

class EmbryoFormCard extends StatefulWidget {
  const EmbryoFormCard({super.key, required this.autoID, required this.embryo});

  final ValueNotifier<bool> autoID;
  final EmbryoData embryo;

  @override
  State<EmbryoFormCard> createState() => _EmbryoFormCardState();
}

class _EmbryoFormCardState extends State<EmbryoFormCard>
    with AutomaticKeepAliveClientMixin {
  late final String _defaultID;
  late final TextEditingController _idController;
  bool _enteredID = false;
  bool _hasError = false;
  bool _wasFocused = false;

  final FocusNode _fieldFocus = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _defaultID = widget.embryo.id;
    _idController = TextEditingController(
        text: !widget.autoID.value ? '' : widget.embryo.id);
    widget.autoID.addListener(_handleAutoIDChange);
    _fieldFocus.addListener(() {
      if (_wasFocused && !_fieldFocus.hasFocus) {
        _handleSubmit(_idController.text);
      }
      _wasFocused = _fieldFocus.hasFocus;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    widget.autoID.removeListener(_handleAutoIDChange);
    _fieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const disabledBorder = OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(20)));
    const normalBorder =
        OutlineInputBorder(borderSide: BorderSide(color: Colors.black));
    const errorBorder =
        OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(20),
            border: _hasError ? Border.all(color: Colors.red, width: 2) : null,
            boxShadow: [
              BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6))
            ]),
        child: Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text('E${widget.embryo.embryoNumber.toString()}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.w500))),
              const SizedBox(width: 10),
              Text('Embryo ID:',
                  style: Theme.of(context).textTheme.headlineSmall)
            ]),
            const SizedBox(height: 10),
            Expanded(
                child: ValueListenableBuilder(
              valueListenable: widget.autoID,
              builder: (_, autoIDEmbryo, __) {
                return TextFormField(
                  focusNode: _fieldFocus,
                  controller: _idController,
                  enabled: !autoIDEmbryo,
                  decoration: InputDecoration(
                      hintText: autoIDEmbryo
                          ? null
                          : _hasError
                              ? 'Embryo needs an ID'
                              : 'Enter ID: (e.g. $_defaultID)',
                      hintStyle: _hasError
                          ? Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red)
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: autoIDEmbryo || _enteredID
                          ? Colors.grey.shade400
                          : Theme.of(context).colorScheme.onPrimary,
                      disabledBorder: disabledBorder,
                      focusedBorder: normalBorder,
                      errorBorder: _hasError
                          ? errorBorder
                          : _enteredID
                              ? disabledBorder
                              : normalBorder,
                      focusedErrorBorder:
                          _hasError ? errorBorder : normalBorder,
                      errorStyle:
                          const TextStyle(fontSize: 0, color: Colors.black),
                      border: autoIDEmbryo
                          ? disabledBorder
                          : _enteredID
                              ? disabledBorder
                              : normalBorder),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 21,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500),

                  // Logic Section
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _hasError = true;
                      });
                      return '';
                    }
                    return null;
                  },
                  onFieldSubmitted: _handleSubmit,
                  onTap: () => setState(() {
                    _enteredID = false;
                    _hasError = false;
                  }),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _handleSubmit(_idController.text);
                  },
                );
              },
            ))
          ],
        ));
  }

  void _handleAutoIDChange() {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    if (widget.autoID.value) {
      if (_idController.text.isEmpty) {
        _idController.text = _defaultID; // only change the value if empty
      }
      setState(() {
        _enteredID =
            true; // whenever autoID is true, the ID is considered entered
      });
    } else {
      bool isEntered = true;
      if (_idController.text == _defaultID) {
        _idController.text = '';
        isEntered = false;
      }
      setState(() {
        _enteredID = isEntered;
      });
    }
  }

  void _handleSubmit(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _enteredID = true;
        widget.embryo.id = text;
      });
    }
  }
}
