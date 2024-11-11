import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/data/api/api_service.dart';
import 'package:smart_farmer_app/data/local/auth_repository.dart';
import 'package:smart_farmer_app/model/detail_laporan.dart';
import 'package:smart_farmer_app/provider/detail_laporan_provider.dart';
import 'package:smart_farmer_app/screen/widgets/alert_dialog.dart';
import 'package:smart_farmer_app/screen/widgets/button.dart';
import 'package:smart_farmer_app/screen/widgets/text_field.dart';
import 'package:smart_farmer_app/screen/widgets/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailLaporanScreen extends StatefulWidget {
  const DetailLaporanScreen({
    super.key,
    required this.idLaporan,
    required this.kategori,
  });

  final String idLaporan;
  final String kategori;

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  final _jumlahController = TextEditingController();
  final _ciriCiriController = TextEditingController();
  String? actor;

  @override
  void initState() {
    super.initState();
    checked = List<bool>.filled(ciriCiriList.length, false);
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

  final List<String> ciriCiriList = [
    "Tidak Ada Gerakan atau Respon",
    "Tubuh Kaku",
    "Tidak Ada Pernafasan",
    "Penurunan Suhu Tubuh",
    "Mata Tertutup atau Sayu",
  ];

  List<bool> checked = [];
  final String otherOption = "Lainnya";
  bool isOtherChecked = false;

  @override
  void dispose() {
    super.dispose();
    _jumlahController.dispose();
    _ciriCiriController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Detail Laporan'),
            Text(
              widget.kategori,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ChangeNotifierProvider<DetailLaporanProvider>(
        create: (context) => DetailLaporanProvider(
          apiService: ApiService(),
          authRepository: AuthRepository(),
          idLaporan: widget.idLaporan,
        ),
        builder: (context, child) {
          return Consumer<DetailLaporanProvider>(
            builder: (context, provider, _) {
              final state = provider.loadingState;
              return state.when(
                initial: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                loaded: () {
                  final data = provider.detailLaporanResponse!.data;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBody(data, provider),
                  );
                },
                error: (e) {
                  return Center(
                    child: Text(e),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(DetailLaporan data, DetailLaporanProvider provider) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Stack(
            children: [
              _buildDetailLaporan(data, orientation, provider),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: data.status == 'pending' && isOwner
                    ? _buildButtonConfirmation(provider)
                    : const SizedBox.shrink(),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: _buildDetailLaporan(data, orientation, provider),
          );
        }
      },
    );
  }

  Widget _buildDetailLaporan(DetailLaporan data, Orientation orientation,
      DetailLaporanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: data.status == 'pending'
                ? const Color(0xFFC1C05C)
                : data.status == 'approved'
                    ? const Color(0xFF809577)
                    : const Color(0xFFAD6466),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                data.status == 'pending'
                    ? 'Menunggu Konfirmasi'
                    : data.status == 'approved'
                        ? 'Disetujui'
                        : 'Ditolak',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tanggal',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd MMM yyyy').format(data.tanggal),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.kategori == 'Kematian Ayam'
              ? 'Jumlah Ayam'
              : widget.kategori == 'Hasil Panen Telur'
                  ? 'Jumlah Telur'
                  : 'Rata-rata (Kg)',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomTextField(
              controller: _jumlahController,
              text: widget.kategori == 'Kematian Ayam'
                  ? data.jumlah.toString()
                  : widget.kategori == 'Hasil Panen Telur'
                      ? data.totalTelur.toString()
                      : data.totalBerat.toString(),
              enabled: false,
              hintText: 'Jumlah',
              labelText: widget.kategori == 'Kematian Ayam'
                  ? 'Jumlah Ayam'
                  : widget.kategori == 'Hasil Panen Telur'
                      ? 'Jumlah Telur'
                      : 'Rata-rata',
            ),
            widget.kategori == 'Hasil Panen Telur'
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'dari ${data.totalAyam} Ayam',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 16),
        widget.kategori == 'Kematian Ayam'
            ? _buildBodyKematianAyam(data, orientation, provider)
            : widget.kategori == 'Hasil Panen Telur'
                ? _buildBodyPanenTelur(data, orientation, provider)
                : _buildBodyAyamPedaging(data, orientation, provider),
      ],
    );
  }

  void _initializeCheckedState(DetailLaporan data) {
    checked = List<bool>.filled(ciriCiriList.length, false);
    isOtherChecked = false;

    List<String> inputCiriCiri = data.ciriCiri?.split(', ') ?? [];

    List<String> unmatchedCiriCiri = [];
    for (String item in inputCiriCiri) {
      if (ciriCiriList.contains(item)) {
        int index = ciriCiriList.indexOf(item);
        checked[index] = true;
      } else {
        unmatchedCiriCiri.add(item);
      }
    }

    if (unmatchedCiriCiri.isNotEmpty) {
      isOtherChecked = true;
      _ciriCiriController.text = unmatchedCiriCiri.join(', ');
    }
  }

  Widget _buildBodyKematianAyam(DetailLaporan data, Orientation orientation,
      DetailLaporanProvider provider) {
    _initializeCheckedState(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ciri-ciri Ayam',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: ciriCiriList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: checked[index],
                  onChanged: (bool? value) {},
                ),
                const SizedBox(width: 12),
                Text(
                  ciriCiriList[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isOtherChecked,
              onChanged: (bool? value) {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  const Text('Lainnya', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _ciriCiriController,
                    enabled: false,
                    minLines: 4,
                    hintText: 'Lainnya',
                    labelText: 'Lainnya',
                  ),
                ],
              ),
            ),
          ],
        ),
        if (orientation == Orientation.landscape)
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            child: data.status == 'pending' && isOwner
                ? _buildButtonConfirmation(provider)
                : const SizedBox.shrink(),
          )
      ],
    );
  }

  Widget _buildBodyPanenTelur(DetailLaporan data, Orientation orientation,
      DetailLaporanProvider provider) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        if (orientation == Orientation.landscape)
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 25),
            child: data.status == 'pending' && isOwner
                ? _buildButtonConfirmation(provider)
                : const SizedBox.shrink(),
          )
      ],
    );
  }

  Widget _buildBodyAyamPedaging(DetailLaporan data, Orientation orientation,
      DetailLaporanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampiran',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        data.images == null || data.images!.isEmpty
            ? const Text('Tidak ada lampiran')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: data.images!.length,
                itemBuilder: (context, index) {
                  final image = data.images![index];
                  return InkWell(
                    onTap: () {
                      showImageViewer(
                        context,
                        Image.network(image.url).image,
                        doubleTapZoomable: true,
                        swipeDismissible: true,
                        useSafeArea: true,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        image.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
        if (orientation == Orientation.landscape)
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            child: data.status == 'pending' && isOwner
                ? _buildButtonConfirmation(provider)
                : const SizedBox.shrink(),
          )
      ],
    );
  }

  Widget _buildButtonConfirmation(DetailLaporanProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red),
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyAlertDialog(
                      title: 'Tolak Laporan',
                      description:
                          'Apakah anda yakin ingin menolak laporan ini?',
                      msgAccept: 'Tolak',
                      onAccept: () {
                        provider
                            .updateStatusLaporan(
                          idLaporan: widget.idLaporan,
                          status: 'rejected',
                          kategori: widget.kategori,
                        )
                            .then((value) {
                          if (provider.uploadResponse!.success) {
                            provider.getDetailLaporan(id: widget.idLaporan);
                            ToastMessage.show(context, 'Laporan ditolak');
                          }
                        }).catchError((e) {
                          ToastMessage.show(context, e.toString());
                        });
                        context.pop();
                      },
                      msgCancel: 'Batal',
                      onCancel: () {
                        context.pop();
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tolak',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 50 * 0.35,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
              function: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyAlertDialog(
                      title: 'Terima Laporan',
                      description:
                          'Apakah anda yakin ingin menerima laporan ini?',
                      msgAccept: 'Terima',
                      onAccept: () {
                        provider
                            .updateStatusLaporan(
                          idLaporan: widget.idLaporan,
                          status: 'approved',
                          kategori: widget.kategori,
                        )
                            .then((value) {
                          if (provider.uploadResponse!.success) {
                            provider.getDetailLaporan(id: widget.idLaporan);
                          }
                        });
                        context.pop();
                      },
                      msgCancel: 'Batal',
                      onCancel: () {
                        context.pop();
                      },
                    );
                  },
                );
              },
              text: 'Terima'),
        ),
      ],
    );
  }
}
