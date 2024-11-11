import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/common/loading_state.dart';
import 'package:smart_farmer_app/common/resources.dart';
import 'package:smart_farmer_app/data/api/api_service.dart';
import 'package:smart_farmer_app/data/local/auth_repository.dart';
import 'package:smart_farmer_app/model/detail_kandang.dart';
import 'package:smart_farmer_app/provider/detail_kandang_provider.dart';
import 'package:smart_farmer_app/provider/kandang_provider.dart';
import 'package:smart_farmer_app/screen/widgets/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailKandangScreen extends StatefulWidget {
  const DetailKandangScreen({super.key, required this.idKandang});

  final String idKandang;

  @override
  State<DetailKandangScreen> createState() => _DetailKandangScreenState();
}

class _DetailKandangScreenState extends State<DetailKandangScreen> {
  late KandangProvider _inventoryProvider;
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

    _inventoryProvider = Provider.of<KandangProvider>(context, listen: false);
  }

  void _onSelected(value, DetailKandang detailInventory) {
    switch (value) {
      case 'Edit':
        context.goNamed('edit_kandang', extra: {
          'idKandang': widget.idKandang,
          'detailKandang': detailInventory,
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
                  _inventoryProvider
                      .deleteKandang(idKandang: widget.idKandang)
                      .then((value) {
                    if (_inventoryProvider.uploadResponse!.success) {
                      context.pop();
                      _inventoryProvider.refreshKandang();
                      ToastMessage.show(context, 'Kandang deleted');
                      context.pop();
                    } else {
                      ToastMessage.show(context, 'Failed to delete kandang');
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
    return ChangeNotifierProvider<DetailKandangProvider>(
      create: (context) => DetailKandangProvider(
        apiService: ApiService(),
        authRepository: AuthRepository(),
        idKandang: widget.idKandang,
      ),
      child: Scaffold(
        body: Consumer<DetailKandangProvider>(
          builder: (context, provider, child) {
            final state = provider.loadingState;
            return RefreshIndicator(
                onRefresh: () {
                  return provider.getDetailKandang(idKandang: widget.idKandang);
                },
                child: _buildBody(context, provider, state));
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DetailKandangProvider provider,
      LoadingState state) {
    return Stack(
      children: [
        state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: () {
            final detailInventory = provider.detailKandangResponse!.result;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildAppBar(DetailKandangProvider provider) {
    final detailCommodity = provider.detailKandangResponse?.result;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _inventoryProvider.refreshKandang();
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

  Widget _buildCarousel(BuildContext context,
      DetailKandangProvider inventoryProvider, DetailKandang detailInventory) {
    return CarouselSlider(
      items: detailInventory.kandangImages.map((index) {
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
        autoPlay: detailInventory.kandangImages.length > 1 ? true : false,
        enableInfiniteScroll:
            detailInventory.kandangImages.length > 1 ? true : false,
      ),
    );
  }

  Widget _buildDetailCommodity(BuildContext context,
      DetailKandang detailCommodity, DetailKandangProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                detailCommodity.nama,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Resources().primaryColor,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Resources().primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    detailCommodity.lokasi,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/chicken-alive.svg',
                width: 20,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  text: detailCommodity.jumlahAyam.toString(),
                  children: const [
                    TextSpan(
                      text: ' ekor',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
