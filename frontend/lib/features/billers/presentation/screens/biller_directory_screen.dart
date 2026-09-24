import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/biller_provider.dart';
import '../widgets/biller_category_chip.dart';
import '../widgets/biller_list_tile.dart';

class BillerDirectoryScreen
    extends ConsumerStatefulWidget {
  const BillerDirectoryScreen({
    super.key,
  });

  @override
  ConsumerState<BillerDirectoryScreen>
      createState() =>
          _BillerDirectoryScreenState();
}

class _BillerDirectoryScreenState
    extends ConsumerState<
        BillerDirectoryScreen> {
  final _searchController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedState;

  BillerDirectoryFilter get _filter {
    return BillerDirectoryFilter(
      category:
          _selectedCategory,
      query:
          _searchController.text,
      state: _selectedState,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(
      billerDirectoryProvider(
        _filter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(
      billerCategoriesProvider,
    );

    final billers =
        ref.watch(
      billerDirectoryProvider(
        _filter,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Billers'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration:
                  InputDecoration(
                hintText:
                    'Search billers',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _searchController
                            .text
                            .isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController
                                  .clear();

                              setState(
                                () {},
                              );
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          ),
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(
            height: 48,
            child: categories.when(
              loading: () =>
                  const Center(
                child:
                    CircularProgressIndicator(),
              ),
              error: (_, __) =>
                  const Center(
                child: Text(
                  'Unable to load categories',
                ),
              ),
              data: (items) {
                return ListView.separated(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      items.length + 1,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(
                    width: 8,
                  ),
                  itemBuilder:
                      (context, index) {
                    if (index == 0) {
                      return BillerCategoryChip(
                        category: 'all',
                        selected:
                            _selectedCategory ==
                                null,
                        onTap: () {
                          setState(() {
                            _selectedCategory =
                                null;
                          });
                        },
                      );
                    }

                    final category =
                        items[index - 1];

                    return BillerCategoryChip(
                      category:
                          category,
                      selected:
                          _selectedCategory ==
                              category,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              category;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
            ),
            child:
                DropdownButtonFormField<
                    String>(
              initialValue:
                  _selectedState,
              decoration:
                  const InputDecoration(
                labelText: 'State',
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'MH',
                  child: Text(
                    'Maharashtra',
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedState =
                      value;
                });
              },
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Expanded(
            child: billers.when(
              loading: () =>
                  const Center(
                child:
                    CircularProgressIndicator(),
              ),
              error: (_, __) =>
                  Center(
                child: FilledButton(
                  onPressed: _refresh,
                  child:
                      const Text(
                    'Retry',
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No billers found',
                    ),
                  );
                }

                return ListView.separated(
                  itemCount:
                      items.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(
                    height: 1,
                  ),
                  itemBuilder:
                      (context, index) {
                    final biller =
                        items[index];

                    return BillerListTile(
                      biller: biller,
                      onTap: () {
                        context.push(
                          '/billers/${biller.id}/add',
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}