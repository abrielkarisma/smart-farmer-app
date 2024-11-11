import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smart_farmer_app/common/loading_state.dart';
import 'package:smart_farmer_app/data/api/api_service.dart';
import 'package:smart_farmer_app/data/local/auth_repository.dart';
import 'package:smart_farmer_app/model/detail_inventory.dart';
import 'package:smart_farmer_app/provider/detail_inventory_provider.dart';
import 'package:smart_farmer_app/provider/inventory_provider.dart';
import 'package:smart_farmer_app/screen/widgets/button.dart';
import 'package:smart_farmer_app/screen/widgets/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailInventoryScreen extends StatefulWidget {
  const DetailInventoryScreen(
      {super.key,
      required this.id,
      required this.category,
      required this.kandangId});

  final String id;
  final String category;
  final String kandangId;

  @override
  State<DetailInventoryScreen> createState() => _DetailInventoryScreenState();
}

class _DetailInventoryScreenState extends State<DetailInventoryScreen> {
  late InventoryProvider _inventoryProvider;
  String? actor;

  @override
  void initState() {
    super.initState();
    _checkActor();
  }

  Future<void> _checkActor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      actor = prefs.getString('user_role');
    });
  }
  // final actor = const String.fromEnvironment('actor', defaultValue: 'pemilik');

  bool get isOwner => actor == 'pemilik';
  bool get isEmployee => actor == 'petugas';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
  }

  void _onSelected(value, DetailInventory detailInventory) {
    switch (value) {
      case 'Edit':
        context.goNamed('edit_inventory', pathParameters: {
          'id': widget.id
        }, extra: {
          'idKandang': widget.kandangId,
          'category': widget.category,
          'detailInventory': detailInventory,
        });
        break;
      case 'Delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Confirmation'),
            content: const Text('Are you sure want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _inventoryProvider.deleteInventory(widget.id).then((value) {
                    if (_inventoryProvider.uploadResponse!.success) {
                      context.pop();
                      _inventoryProvider.refreshInventory(
                          idKandang: "e15e286c-aa40-474d-9baa-5f79912205e3",
                          category: widget.category);
                      ToastMessage.show(context, 'Commodity deleted');
                      context.pop();
                    } else {
                      ToastMessage.show(context, 'Failed to delete commodity');
                    }
                  }).catchError((onError) {
                    ToastMessage.show(context, onError.toString());
                  });
                },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailInventoryProvider>(
      create: (context) => DetailInventoryProvider(
        apiService: ApiService(),
        authRepository: AuthRepository(),
        id: widget.id,
      ),
      child: Scaffold(
        body: Consumer<DetailInventoryProvider>(
          builder: (context, provider, child) {
            final state = provider.loadingState;
            return RefreshIndicator(
                onRefresh: () {
                  return provider.getDetailInventory(idInventory: widget.id);
                },
                child: _buildBody(context, provider, state));
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DetailInventoryProvider provider,
      LoadingState state) {
    return Stack(
      children: [
        state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: () {
            final detailInventory = provider.detailInventoryResponse!.data;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCarousel(context, provider, detailInventory),
                  _buildDetailCommodity(context, detailInventory, provider),
                ],
              ),
            );
          },
          error: (message) => Center(child: Text(message)),
        ),
        IgnorePointer(
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          child: _buildAppBar(provider),
        ),
      ],
    );
  }

  Widget _buildAppBar(DetailInventoryProvider provider) {
    final detailCommodity = provider.detailInventoryResponse?.data;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _inventoryProvider.refreshInventory(
                idKandang: "e15e286c-aa40-474d-9baa-5f79912205e3",
                category: widget.category);
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        const Text(
          'Detail Inventory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        isOwner
            ? PopupMenuButton(
                onSelected: (String value) {
                  _onSelected(value, detailCommodity!);
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'Edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ];
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              )
            : const SizedBox(
                width: 24,
              ),
      ],
    );
  }

  Widget _buildCarousel(
      BuildContext context,
      DetailInventoryProvider inventoryProvider,
      DetailInventory detailInventory) {
    return CarouselSlider(
      items: detailInventory.images.map((index) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Image.network(
                index.url,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        aspectRatio: 1.2,
        viewportFraction: 1,
        autoPlay: detailInventory.images.length > 1 ? true : false,
        enableInfiniteScroll: detailInventory.images.length > 1 ? true : false,
      ),
    );
  }

  // Widget _buildImage(
  //     DetailInventoryProvider provider, DetailInventory detailCommodity) {
  //   return ClipRRect(
  //     borderRadius: const BorderRadius.only(
  //       bottomLeft: Radius.circular(20),
  //       bottomRight: Radius.circular(20),
  //     ),
  //     child: Image.network(
  //       detailCommodity.images.first,
  //       fit: BoxFit.cover,
  //       height: MediaQuery.of(context).size.height / 1.8,
  //       width: double.infinity,
  //       loadingBuilder: (BuildContext context, Widget child,
  //           ImageChunkEvent? loadingProgress) {
  //         if (loadingProgress == null) {
  //           return child;
  //         } else {
  //           return Center(
  //             child: CircularProgressIndicator(
  //               value: loadingProgress.expectedTotalBytes != null
  //                   ? loadingProgress.cumulativeBytesLoaded /
  //                       (loadingProgress.expectedTotalBytes ?? 1)
  //                   : null,
  //             ),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

  Widget _buildDetailCommodity(BuildContext context,
      DetailInventory detailCommodity, DetailInventoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            detailCommodity.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF293869),
            ),
          ),
          const SizedBox(height: 8),
          Text('Jenis: ${detailCommodity.jenis}'),
          const SizedBox(height: 8),
          const Text('Current Stock'),
          const SizedBox(height: 8),
          _buildStockSection(context, provider),
          const SizedBox(height: 80),
          provider.commodityStock != provider.currentStock
              ? provider.loadingState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: () => CustomButton(
                    function: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Update Stock'),
                            content: const Text(
                                'Are you sure want to update this item stock?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  context.pop();
                                  _updateStock(provider);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    text: 'Update Stock',
                  ),
                  error: (message) => Text(message),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _updateStock(DetailInventoryProvider provider) async {
    await provider.updateStock().then((value) {
      if (provider.uploadResponse!.success) {
        provider.getDetailInventory(idInventory: widget.id);
        if (mounted) {
          ToastMessage.show(context, provider.uploadResponse!.message);
        }
      } else {
        if (mounted) {
          ToastMessage.show(context, provider.uploadResponse!.message);
        }
      }
    }).catchError((onError) {
      if (mounted) {
        ToastMessage.show(context, onError.toString());
      }
    });
    // if (mounted) {
    //   ToastMessage.show(context, 'Stock Updated');
    //   context.goNamed('more_commodity', pathParameters: {'id': widget.storeId});
    // }
  }

  Widget _buildStockSection(
      BuildContext context, DetailInventoryProvider provider) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              provider.decreaseStock();
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4E6B3E),
                borderRadius: BorderRadius.circular(15),
              ),
              height: 50,
              width: 50,
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          ),
          Text(
            provider.commodityStock.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF293869),
            ),
          ),
          InkWell(
            onTap: () {
              provider.increaseStock();
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4E6B3E),
                borderRadius: BorderRadius.circular(15),
              ),
              height: 50,
              width: 50,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
