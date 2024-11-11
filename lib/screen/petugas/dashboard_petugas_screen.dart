import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/model/kandang_petugas.dart';
import 'package:smart_farmer_app/provider/kandang_provider.dart';

class DashboardPetugasScreen extends StatefulWidget {
  const DashboardPetugasScreen({super.key});

  @override
  State<DashboardPetugasScreen> createState() => _DashboardPetugasScreenState();
}

class _DashboardPetugasScreenState extends State<DashboardPetugasScreen> {
  late KandangProvider kandangProvider;

  @override
  void initState() {
    super.initState();

    kandangProvider = context.read<KandangProvider>();

    Future.microtask(() {
      kandangProvider.getKandangByPetugas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KandangProvider>(
      builder: (context, kandangProvider, child) {
        final state = kandangProvider.loadingState;
        return Scaffold(
          floatingActionButton: state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            loaded: () {
              final data = kandangProvider.kandangPetugasResponse?.result;
              if (data != null) {
                return _buildFloatingActionButton(data);
              } else {
                return const SizedBox.shrink();
              }
            },
            error: (message) => const SizedBox.shrink(),
          ),
          body: state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: () {
              final data = kandangProvider.kandangPetugasResponse!.result;
              return _buildBody(data);
            },
            error: (message) => Center(
              child: Text(message),
            ),
          ),
        );
      },
    );
  }

  Padding _buildBody(KandangPetugasResult data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLocation(data),
          const SizedBox(height: 16),
          const Text(
            'Data Ayam',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 11,
                            offset: Offset(3, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(13, 15),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 27,
                            offset: Offset(29, 34),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x02000000),
                            blurRadius: 31,
                            offset: Offset(51, 60),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x00000000),
                            blurRadius: 34,
                            offset: Offset(80, 93),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Suhu Kandang',
                                  style: TextStyle(
                                    color: Color(0xFF101010),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '31',
                                          style: TextStyle(
                                            color: Color(0xFF101010),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'o',
                                          style: TextStyle(
                                            color: Color(0xFF101010),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Cukup Baik',
                                      style: TextStyle(
                                        color: Color(0xFF101010),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              right: -30,
                              bottom: -13,
                              child: Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/cloud.svg',
                                  width: 80,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFE2F10F), BlendMode.srcIn),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 11,
                            offset: Offset(3, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(13, 15),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 27,
                            offset: Offset(29, 34),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x02000000),
                            blurRadius: 31,
                            offset: Offset(51, 60),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x00000000),
                            blurRadius: 34,
                            offset: Offset(80, 93),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pakan Ayam',
                                  style: TextStyle(
                                    color: Color(0xFF101010),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '5',
                                          style: TextStyle(
                                            color: Color(0xFF101010),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            'ltr',
                                            style: TextStyle(
                                              color: Color(0xFF101010),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Cukup Baik',
                                      style: TextStyle(
                                        color: Color(0xFF101010),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              right: -30,
                              bottom: -20,
                              child: Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/pakan.svg',
                                  width: 90,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF2985E6), BlendMode.srcIn),
                                ),
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 11,
                            offset: Offset(3, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(13, 15),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 27,
                            offset: Offset(29, 34),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x02000000),
                            blurRadius: 31,
                            offset: Offset(51, 60),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x00000000),
                            blurRadius: 34,
                            offset: Offset(80, 93),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disinfektan',
                                  style: TextStyle(
                                    color: Color(0xFF101010),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '10',
                                          style: TextStyle(
                                            color: Color(0xFF101010),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            'ml',
                                            style: TextStyle(
                                              color: Color(0xFF101010),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Sisa dari 100ml',
                                      style: TextStyle(
                                        color: Color(0xFF101010),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              right: -25,
                              bottom: -17,
                              child: Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/disinfektan.svg',
                                  width: 100,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFFF0000), BlendMode.srcIn),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 11,
                            offset: Offset(3, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(13, 15),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 27,
                            offset: Offset(29, 34),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x02000000),
                            blurRadius: 31,
                            offset: Offset(51, 60),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x00000000),
                            blurRadius: 34,
                            offset: Offset(80, 93),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bobot Ayam Pedaging',
                                  style: TextStyle(
                                    color: Color(0xFF101010),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '12',
                                          style: TextStyle(
                                            color: Color(0xFF101010),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            'kg',
                                            style: TextStyle(
                                              color: Color(0xFF101010),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Cukup Baik',
                                      style: TextStyle(
                                        color: Color(0xFF101010),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              right: -5,
                              bottom: -10,
                              child: Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/chicken-meat.svg',
                                  width: 80,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFC88A05), BlendMode.srcIn),
                                ),
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLocation(KandangPetugasResult data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7A8E70),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alamat',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                '${data.kandang.nama}, ${data.kandang.lokasi}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF4E6B3E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(KandangPetugasResult data) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF4E6B3E),
      ),
      child: FloatingActionButton(
        onPressed: () {
          _buildBottomSheet(context, data);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _buildBottomSheet(
    BuildContext context,
    KandangPetugasResult data,
  ) {
    return showModalBottomSheet<void>(
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
                          'Pilih Jenis Laporan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E6B3E),
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
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        context.pop();
                        context.goNamed('add_laporan_kematian', extra: {
                          'idKandang': data.kandang.id,
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/chicken-dead.svg',
                              width: 25,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Laporan Kematian Ayam',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    InkWell(
                      onTap: () {
                        context.pop();
                        context.goNamed('add_laporan_telur', extra: {
                          'idKandang': data.kandang.id,
                          'totalAyam': data.kandang.totalAyam.toString(),
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/egg.svg',
                              width: 25,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Laporan Hasil Panen Telur',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    InkWell(
                      onTap: () {
                        context.pop();
                        context.goNamed('add_laporan_pedaging', extra: {
                          'idKandang': data.kandang.id,
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/chicken-meat.svg',
                              width: 25,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Laporan Hasil Panen Ayam Pedaging',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
