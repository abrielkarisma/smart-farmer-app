import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/model/kandang.dart';
import 'package:smart_farmer_app/provider/inventory_provider.dart';
import 'package:smart_farmer_app/provider/kandang_provider.dart';
import 'package:smart_farmer_app/screen/widgets/search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.category});

  final String category;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? actor;

  Future<void> _checkActor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      actor = prefs.getString('user_role');
    });
  }
  // final actor = const String.fromEnvironment('actor', defaultValue: 'pemilik');

  bool get isOwner => actor == 'pemilik';
  bool get isEmployee => actor == 'petugas';

  List<String> category = ['Semua', 'Pedaging', 'Petelur'];

  String selectedCategory = '';

  late KandangProvider kandangProvider;

  // Kandang? _selectedKandang;

  @override
  void initState() {
    _checkActor();
    super.initState();
    final inventoryProvider = context.read<InventoryProvider>();
    if (!isEmployee) {
      kandangProvider = context.read<KandangProvider>();
    }

    selectedCategory = category.first;

    Future.microtask(() async {
      if (!isEmployee) {
        await kandangProvider.refreshKandang().then(
          (value) {
            if (kandangProvider.kandangResponse != null) {
              kandangProvider.setSelectedKandang(
                  kandang: kandangProvider.kandangResponse!.result.data.first);
            } else {
              kandangProvider.setSelectedKandang(kandang: null);
            }
          },
        );
      }
      await inventoryProvider.refreshInventory(
          idKandang: !isEmployee ? kandangProvider.selectedKandang!.id : '',
          category:
              widget.category == 'Pakan' ? selectedCategory : widget.category);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (inventoryProvider.pageItems != null) {
          inventoryProvider.getAllInventory(
              idKandang: !isEmployee ? kandangProvider.selectedKandang!.id : '',
              category: widget.category == 'Pakan'
                  ? selectedCategory
                  : widget.category);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      context.read<InventoryProvider>().refreshInventory(
            idKandang: !isEmployee ? kandangProvider.selectedKandang!.id : '',
            searchValue: query,
            category:
                widget.category == 'Pakan' ? selectedCategory : widget.category,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<InventoryProvider, KandangProvider>(
        builder: (context, inventoryProvider, kandangProvider, child) {
          return _buildDetail(inventoryProvider, kandangProvider);
        },
      ),
      floatingActionButton: !isEmployee ? _buildFAB() : null,
    );
  }

  Widget _buildDetail(
      InventoryProvider inventoryProvider, KandangProvider kandangProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySearchBar(
                searchController: _searchController,
                onChanged: (value) {
                  _onSearchChanged(value!);
                },
                hintText: 'Search inventory...',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.category == 'Pakan'
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFE9ECF2),
                        ),
                        child: DropdownButton<String>(
                          value: selectedCategory.isNotEmpty
                              ? selectedCategory
                              : category.first,
                          underline: const SizedBox(),
                          items: category.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                            context.read<InventoryProvider>().refreshInventory(
                                  idKandang:
                                      kandangProvider.selectedKandang!.id,
                                  category: selectedCategory,
                                );
                          },
                        ),
                      )
                    : const SizedBox(),
                if (!isEmployee)
                  InkWell(
                    onTap: () => _buildBottomSheet(
                        context, context.read<KandangProvider>()),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                        Text(
                            kandangProvider.selectedKandang?.nama ??
                                'Pilih Kandang',
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
              ],
            )),
        const SizedBox(height: 8),
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildList(inventoryProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF4E6B3E),
      ),
      child: FloatingActionButton(
        onPressed: () {
          context.goNamed(
            'add_inventory',
            extra: {
              'idKandang': kandangProvider.selectedKandang!.id,
              'category': widget.category,
            },
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(InventoryProvider provider) {
    final state = provider.loadingState;
    return state.when(
      initial: () {
        return const SizedBox.shrink();
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      loaded: () {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<InventoryProvider>().refreshInventory(
                  idKandang:
                      !isEmployee ? kandangProvider.selectedKandang!.id : '',
                  category: widget.category == 'Pakan'
                      ? selectedCategory
                      : widget.category,
                );
          },
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final commodities = provider.inventories[index];
              return InkWell(
                onTap: () {
                  // if (isOwner) {
                  //   context.goNamed('detail_inventory', pathParameters: {
                  //     'id': idKandang,
                  //     'inventoryId': commodities.id,
                  //   });
                  // } else {
                  //   context.goNamed('detail_inventory', pathParameters: {
                  //     'inventoryId': commodities.id,
                  //   }, extra: {
                  //     'id': idKandang,
                  //   });
                  // }
                  context.goNamed('detail_inventory', pathParameters: {
                    'id': commodities.id,
                  }, extra: {
                    'category': widget.category,
                    'idKandang':
                        !isEmployee ? kandangProvider.selectedKandang!.id : '',
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image.network(
                          commodities.images.first.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commodities.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'stock : ${commodities.stock}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: provider.inventories.length,
          ),
        );
      },
      error: (e) {
        return Center(
          child: Text(e.toString()),
        );
      },
    );
  }

  Future<void> _buildBottomSheet(
      BuildContext context, KandangProvider kandangProvider) {
    final state = kandangProvider.loadingState;
    return showModalBottomSheet<void>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Pilih Kandang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: state.when(
                    initial: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    loaded: () => ListView.builder(
                      itemCount: kandangProvider.listKandang.length,
                      itemBuilder: (context, index) {
                        final kandang = kandangProvider.listKandang[index];
                        bool isSame =
                            kandangProvider.selectedKandang == kandang;
                        return _buildItemKandang(
                            kandang, kandangProvider, isSame);
                      },
                    ),
                    error: (error) => Center(child: Text(error)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemKandang(
    Kandang kandang,
    KandangProvider kandangProvider,
    bool isSame,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          kandangProvider.selectedKandang = kandang;
        });
        context.pop();
        context.read<InventoryProvider>().refreshInventory(
              idKandang: kandang.id,
              category: widget.category == 'Pakan'
                  ? selectedCategory
                  : widget.category,
            );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSame ? const Color(0xFF7A8E70) : Colors.white,
          border: Border.all(
            color: const Color(0xFF4E6B3E),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kandang.nama,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSame ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: isSame ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  kandang.lokasi,
                  style: TextStyle(
                    color: isSame ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
