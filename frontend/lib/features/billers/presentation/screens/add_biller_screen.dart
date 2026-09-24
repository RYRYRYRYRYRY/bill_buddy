import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/errors/bank_error.dart';

import '../providers/biller_provider.dart';
import '../widgets/dynamic_biller_form.dart';

class AddBillerScreen
    extends ConsumerStatefulWidget {
  final String billerId;

  const AddBillerScreen({
    super.key,
    required this.billerId,
  });

  @override
  ConsumerState<AddBillerScreen>
      createState() =>
          _AddBillerScreenState();
}

class _AddBillerScreenState
    extends ConsumerState<
        AddBillerScreen> {
  final _nicknameController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  Map<String, String> _params = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
            billerProvider.notifier,
          )
          .loadBiller(
            widget.billerId,
          );
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveBiller() async {
    final current =
        ref.read(billerProvider).value;

    if (current?.biller == null) {
      return;
    }

    if (_nicknameController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Nickname is required.',
          ),
        ),
      );

      return;
    }

    final result =
        await ref
            .read(
              billerProvider.notifier,
            )
            .saveBiller(
              nickname:
                  _nicknameController.text
                      .trim(),
              params: _params,
            );

    if (!mounted) {
      return;
    }

    if (result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Biller saved successfully.',
          ),
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      billerProvider,
      (_, next) {
        next.whenOrNull(
          error: (error, _) {
            final message =
                error is BankError
                    ? error.message
                    : 'Something went wrong. Please try again.';

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content:
                    Text(message),
              ),
            );
          },
        );
      },
    );

    final state =
        ref.watch(billerProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Biller'),
      ),
      body: state.when(
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
        error: (_, __) =>
            Center(
          child: FilledButton(
            onPressed: () {
              ref
                  .read(
                    billerProvider
                        .notifier,
                  )
                  .loadBiller(
                    widget.billerId,
                  );
            },
            child:
                const Text('Retry'),
          ),
        ),
        data: (data) {
          final biller =
              data.biller;

          if (biller == null) {
            return const Center(
              child: Text(
                'Biller not found.',
              ),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Text(
                    biller.name,
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .headlineSmall,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '${biller.category} • ${biller.state}',
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  TextFormField(
                    controller:
                        _nicknameController,
                    validator:
                        (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Nickname is required.';
                      }

                      return null;
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Nickname',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  DynamicBillerForm(
                    biller: biller,
                    onChanged:
                        (values) {
                      _params =
                          values;
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  FilledButton(
                    onPressed:
                        _saveBiller,
                    child: const Text(
                      'Save Biller',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}