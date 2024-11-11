import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_farmer_app/model/detail_inventory.dart';
import 'package:smart_farmer_app/model/detail_kandang.dart';
import 'package:smart_farmer_app/model/detail_laporan.dart';
import 'package:smart_farmer_app/model/detail_petugas.dart';
import 'package:smart_farmer_app/model/history_inventory.dart';
import 'package:smart_farmer_app/model/inventory.dart';
import 'package:smart_farmer_app/model/kandang.dart';
import 'package:smart_farmer_app/model/kandang_petugas.dart';
import 'package:smart_farmer_app/model/laporan.dart';
import 'package:smart_farmer_app/model/login.dart';
import 'package:smart_farmer_app/model/petugas.dart';
import 'package:smart_farmer_app/model/register.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farmer_app/model/statistic.dart';
import 'package:smart_farmer_app/model/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'https://lionfish-app-p99go.ondigitalocean.app';
  static const String baseUrl = 'http://192.168.1.5:3000';
  static const String _auth = '/auth';
  static const String _user = '/user';
  static const String _inventory = '/inventory';
  static const String _kandang = '/kandang';
  static const String _laporan = '/laporan';

  // final actor = const String.fromEnvironment('actor', defaultValue: 'pemilik');
  // String actor = const String.fromEnvironment('actor', defaultValue: 'pemilik');
  // String? actor;
  Future<String?> get actor async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role'); // Memuat role dari SharedPreferences
  }

  Future<bool> get isPemilik async => (await actor) == 'pemilik';
  Future<bool> get isPetugas async => (await actor) == 'petugas';
  Future<bool> get isInvestor async => (await actor) == 'investor';

  /*--------------Auth--------------*/

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final currentActor = await actor; // Ambil nilai actor terbaru
    final role = currentActor == 'pemilik' ? 'petugas' : 'investor';
    final response = await http.post(
      Uri.parse('$baseUrl$_auth/signup'),
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'nama': name,
        'role': role,
        'phone': phone,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_auth/signin'),
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      LoginResponse loginResponse =
          LoginResponse.fromJson(jsonDecode(response.body));
      return loginResponse;
    } else {
      return LoginResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<RegisterResponse> registerPetugas({
    required String name,
    required String email,
    required String password,
    required String kodePemilik,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_auth/signup'),
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'nama': name,
        'role': 'petugas',
        'phone': phone,
        'kode_pemilik': kodePemilik,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      debugPrint(response.body);
      return RegisterResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> getKodeOwner({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_user/kode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Auth--------------*/

  /*--------------Inventory--------------*/

  Future<InventoryResponse> getInventory({
    required String token,
    required String idKandang,
    page = 1,
    pageSize = 10,
    jenis = '',
    name = '',
  }) async {
    final pemilik = await isPemilik;
    final petugas = await isPetugas;
    String url = pemilik
        ? '$baseUrl$_inventory/kandang/$idKandang?page=$page&pageSize=$pageSize&jenis=$jenis&name=$name'
        : petugas
            ? '$baseUrl$_inventory/petugas?page=$page&pageSize=$pageSize&jenis=$jenis&name=$name'
            : '$baseUrl$_inventory/kandang/$idKandang?page=$page&pageSize=$pageSize&jenis=$jenis&name=$name';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return InventoryResponse.fromJson(jsonDecode(response.body));
    } else {
      return InventoryResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<DetailInventoryResponse> getDetailInventory({
    required String token,
    required String idInventory,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_inventory/$idInventory'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DetailInventoryResponse.fromJson(jsonDecode(response.body));
    } else {
      return DetailInventoryResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> createInventory({
    required String token,
    required List<List<int>> images,
    required List<String> filenames,
    required String idKandang,
    required String nama,
    required String jenis,
    required int stock,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$_inventory'),
    );

    for (int i = 0; i < images.length; i++) {
      var multipartFile = http.MultipartFile.fromBytes(
        'images',
        images[i],
        filename: filenames[i],
      );
      request.files.add(multipartFile);
    }

    request.fields.addAll({
      'id_kandang': idKandang,
      'name': nama,
      'jenis': jenis,
      'stock': stock.toString(),
    });

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> updateStock({
    required String token,
    required String idInventory,
    required int stock,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$_inventory/$idInventory'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'stock': stock,
      }),
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> updateInventory({
    required String token,
    required String id,
    List<List<int>>? images,
    List<String>? filenames,
    String? name,
    String? jenis,
    int? stock,
    List<String>? deletedImages,
  }) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl$_inventory/$id'));

    if (images != null) {
      for (int i = 0; i < images.length; i++) {
        var multipartFile = http.MultipartFile.fromBytes(
          'images',
          images[i],
          filename: filenames![i],
        );
        request.files.add(multipartFile);
      }
    }

    if (name != null) request.fields['name'] = name;
    if (stock != null) request.fields['stock'] = stock.toString();
    if (jenis != null) request.fields['jenis'] = jenis;
    if (deletedImages != null) {
      request.fields['deletedImagesId'] = deletedImages.join(',');
    }

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> deleteInventory({
    required String token,
    required String idInventory,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$_inventory/$idInventory'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<HistoryInventoryResponse> getHistoryInventory({
    required String token,
    required String idKandang,
    int page = 1,
    int pageSize = 10,
    String? kategori,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl$_inventory/history/$idKandang?page=$page&pageSize=$pageSize&kategori=$kategori'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return HistoryInventoryResponse.fromJson(jsonDecode(response.body));
    } else {
      return HistoryInventoryResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Inventory--------------*/

  /*--------------Kandang--------------*/

  Future<KandangResponse> getKandang({
    required String token,
    String nama = '',
    page = 1,
    pageSize = 10,
  }) async {
    final pemilik = await isPemilik;
    final petugas = await isPetugas;
    String url = pemilik
        ? '$baseUrl$_kandang?page=$page&pageSize=$pageSize&nama=$nama'
        : petugas
            ? '$baseUrl$_kandang/petugas?page=$page&pageSize=$pageSize&nama=$nama'
            : '$baseUrl$_kandang/investor?page=$page&pageSize=$pageSize&nama=$nama';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return KandangResponse.fromJson(jsonDecode(response.body));
    } else {
      return KandangResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<DetailKandangResponse> getDetailKandang({
    required String token,
    required String idKandang,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_kandang/$idKandang'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DetailKandangResponse.fromJson(jsonDecode(response.body));
    } else {
      return DetailKandangResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> createKandang({
    required String token,
    required String nama,
    required String lokasi,
    required double latitude,
    required double longitude,
    required int jumlahAyam,
    required List<List<int>> images,
    required List<String> filenames,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$_kandang'),
    );

    for (int i = 0; i < images.length; i++) {
      var multipartFile = http.MultipartFile.fromBytes(
        'images',
        images[i],
        filename: filenames[i],
      );
      request.files.add(multipartFile);
    }

    request.fields.addAll({
      'nama': nama,
      'lokasi': lokasi,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'jumlah_ayam': jumlahAyam.toString(),
    });

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> updateKandang({
    required String token,
    required String id,
    List<List<int>>? images,
    List<String>? filenames,
    String? nama,
    String? lokasi,
    double? latitude,
    double? longitude,
    int? jumlahAyam,
    List<String>? deletedImages,
  }) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl$_kandang/$id'));

    if (images != null) {
      for (int i = 0; i < images.length; i++) {
        var multipartFile = http.MultipartFile.fromBytes(
          'images',
          images[i],
          filename: filenames![i],
        );
        request.files.add(multipartFile);
      }
    }

    if (nama != null) request.fields['nama'] = nama;
    if (lokasi != null) request.fields['lokasi'] = lokasi;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (jumlahAyam != null) {
      request.fields['jumlah_ayam'] = jumlahAyam.toString();
    }
    if (deletedImages != null) {
      request.fields['deletedImagesId'] = deletedImages.join(',');
    }

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> deleteKandang({
    required String token,
    required String idKandang,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$_kandang/$idKandang'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<KandangPetugasResponse> getKandangByPetugas({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_kandang/petugas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return KandangPetugasResponse.fromJson(jsonDecode(response.body));
    } else {
      return KandangPetugasResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Kandang--------------*/

  /*--------------Laporan--------------*/

  Future<LaporanResponse> getAllLaporan({
    required String token,
    String jenis = '',
    int page = 1,
    int pageSize = 10,
    String kandang = '',
  }) async {
    final pemilik = await isPemilik;
    final petugas = await isPetugas;
    String url = pemilik
        ? '$baseUrl$_laporan/owner/all?page=$page&pageSize=$pageSize&jenis=$jenis&kandang=$kandang'
        : petugas
            ? '$baseUrl$_laporan/petugas/all?page=$page&pageSize=$pageSize&jenis=$jenis&kandang=$kandang'
            : '$baseUrl$_laporan/investor/all?page=$page&pageSize=$pageSize&jenis=$jenis&kandang=$kandang';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return LaporanResponse.fromJson(jsonDecode(response.body));
    } else {
      return LaporanResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<DetailLaporanResponse> getDetailLaporan({
    required String token,
    required String idLaporan,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_laporan/$idLaporan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DetailLaporanResponse.fromJson(jsonDecode(response.body));
    } else {
      return DetailLaporanResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> updateStatusLaporan({
    required String token,
    required String idLaporan,
    required String status,
    required String kategori,
  }) async {
    String url = kategori == 'Kematian Ayam'
        ? '$baseUrl$_laporan/kematian-ayam/$idLaporan'
        : kategori == 'Hasil Panen Telur'
            ? '$baseUrl$_laporan/panen-telur/$idLaporan'
            : '$baseUrl$_laporan/ayam-pedaging/$idLaporan';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> createLaporanKematian({
    required String token,
    required String idKandang,
    required String ciriKematian,
    required String jumlah,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_laporan/kematian-ayam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id_kandang': idKandang,
        'keterangan': ciriKematian,
        'jumlah': jumlah,
        'tanggal': DateTime.now().toString(),
      }),
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> createLaporanTelur({
    required String token,
    required String idKandang,
    required String jumlah,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_laporan/panen-telur'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id_kandang': idKandang,
        'jumlah': jumlah,
        'tanggal': DateTime.now().toString(),
      }),
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> createLaporanPedaging({
    required String token,
    required String idKandang,
    required String jumlah,
    required List<List<int>> images,
    required List<String> filenames,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$_laporan/ayam-pedaging/sampling'),
    );

    for (int i = 0; i < images.length; i++) {
      var multipartFile = http.MultipartFile.fromBytes(
        'images',
        images[i],
        filename: filenames[i],
      );
      request.files.add(multipartFile);
    }

    request.fields.addAll({
      'id_kandang': idKandang,
      'jumlah': jumlah,
      'tanggal': DateTime.now().toString(),
    });

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Laporan--------------*/

  /*--------------Petugas--------------*/

  Future<PetugasResponse> getAllPetugas({
    required String token,
    String nama = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl$_user/petugas?page=$page&pageSize=$pageSize&nama=$nama'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return PetugasResponse.fromJson(jsonDecode(response.body));
    } else {
      debugPrint(response.body);
      return PetugasResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<DetailPetugasResponse> getDetailPetugas({
    required String token,
    required String idPetugas,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_user/petugas/$idPetugas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DetailPetugasResponse.fromJson(jsonDecode(response.body));
    } else {
      return DetailPetugasResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<UploadResponse> updateLokasiPetugas({
    required String token,
    required String idPetugas,
    required String idKandang,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$_user/petugas/$idPetugas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id_kandang': idKandang,
      }),
    );

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response.body));
    } else {
      return UploadResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Petugas--------------*/

  /*--------------Statistik--------------*/

  Future<StatisticResponse> getStatistik({
    required String token,
    required String idKandang,
    required String jenis,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl$_laporan/statistic/$idKandang?kategori=$jenis&dateStart=$startDate&dateEnd=$endDate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return StatisticResponse.fromJson(jsonDecode(response.body));
    } else {
      debugPrint(response.body);
      return StatisticResponse.fromJson(jsonDecode(response.body));
    }
  }

  /*--------------Statistik--------------*/
}
