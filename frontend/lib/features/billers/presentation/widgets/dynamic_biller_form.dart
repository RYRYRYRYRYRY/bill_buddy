import 'package:flutter/material.dart';

import '../../domain/entities/biller.dart';

class DynamicBillerForm
    extends StatefulWidget {
  final Biller biller;
  final ValueChanged<
      Map<String, String>> onChanged;

  const DynamicBillerForm({
    super.key,
    required this.biller,
    required this.onChanged,
  });

  @override
  State<DynamicBillerForm>
      createState() =>
          _DynamicBillerFormState();
}

class _DynamicBillerFormState
    extends State<DynamicBillerForm> {
  final _formKey =
      GlobalKey<FormState>();

  final Map<String, TextEditingController>
      _controllers = {};

  @override
  void initState() {
    super.initState();

    for (final field
        in widget.biller.fields) {
      _controllers[field.key] =
          TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller
        in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String? _validateField(
    BillerField field,
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '${field.label} is required.';
    }

    try {
      final regex =
          RegExp(field.regex);

      if (!regex.hasMatch(text)) {
        return 'Enter a valid ${field.label}.';
      }
    } catch (_) {
      return 'Unable to validate ${field.label}.';
    }

    return null;
  }

  void _notifyChanged() {
    final values = <String, String>{};

    for (final field
        in widget.biller.fields) {
      values[field.key] =
          _controllers[field.key]!
              .text
              .trim();
    }

    widget.onChanged(values);
  }

  bool validate() {
    return _formKey.currentState
            ?.validate() ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: widget.biller.fields
            .map(
              (field) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                child: TextFormField(
                  controller:
                      _controllers[field.key],
                  onChanged: (_) {
                    _notifyChanged();
                  },
                  validator: (value) =>
                      _validateField(
                    field,
                    value,
                  ),
                  decoration:
                      InputDecoration(
                    labelText:
                        field.label,
                    border:
                        const OutlineInputBorder(),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}