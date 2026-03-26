import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/material.dart';
class ApiService {

  static const String baseUrl =
      "https://tictechnologies.in/stage/gymapp/api";

  static Future<Map<String, String>> headers() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("TOKEN FROM STORAGE: $token");

    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    };
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");

    if (userString == null) return null;

    return jsonDecode(userString);
  }
  /// GET FACILITIES
  static Future<List<dynamic>> getFacilities() async {
    final response = await http.get(
      Uri.parse("$baseUrl/facilities"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        return data["data"];
      }

      return [];
    } else {
      throw Exception("Failed to load facilities");
    }
  }


  /// REGISTER GYM
  static Future<Map<String, dynamic>> registerGym({
    required String gymName,
    required File gymPhoto,
    required String address,
    required double latitude,
    required double longitude,
    required String taxId,
    required String capacity,
    required List<int> facilities,
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/gyms"),
    );

    request.headers.addAll({
      "Accept": "application/json",
    });

    request.fields.addAll({
      "gym_name": gymName,
      "address": address,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "capacity": capacity,
      "tax_id": taxId,
      "selected_facilities": jsonEncode(facilities),
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    /// upload gym image
    request.files.add(
      await http.MultipartFile.fromPath(
        "gym_photo",
        gymPhoto.path,
      ),
    );

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    print("REGISTER STATUS: ${response.statusCode}");
    print("REGISTER BODY: $responseBody");

    return jsonDecode(responseBody);
  }

  /// LOGIN
  static Future<Map<String, dynamic>> login(String email,
      String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {
        "email": email,
        "password": password,
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data["token"]);
      await prefs.setString("user", jsonEncode(data["user"]));
    }

    return data;
  }

  /// FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: {"Accept": "application/json"},
      body: {
        "email": email,
      },
    );

    return jsonDecode(response.body);
  }

  /// RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(String email,
      String token,
      String password,
      String confirmPassword) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reset-password"),
      headers: {"Accept": "application/json"},
      body: {
        "email": email,
        "token": token,
        "password": password,
        "password_confirmation": confirmPassword,
      },
    );

    return jsonDecode(response.body);
  }

  /// gym plans
  static Future<List> getGymPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/gym-plans"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return data["plans"];
    }
    return [];
  }

  static Future<List> getMyGymPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/gym-admin/my-plans"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return data["my_plans"];
    }

    return [];
  }

  static Future<Map> addGymPlan({
    required int adminPlanId,
    required String customPrice,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/gym-admin/select-plan"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
      body: {
        "admin_plan_id": adminPlanId.toString(),
        "custom_price": customPrice,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map> updateGymPlan({
    required int gymPlanId,
    required String price,
    required bool active,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/gym-admin/my-plans/$gymPlanId"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
      body: {
        "custom_price": price,
        "is_active": active ? "1" : "0"
      },
    );

    return jsonDecode(response.body);
  }

  /// GET VIDEO CATEGORIES
  static Future<List> getVideoCategories() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/app/categories"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(res.body);

    return data["data"];
  }

  /// GET MY VIDEOS
  static Future<List> getMyVideos() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/gym/my-videos"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(res.body);

    return data["data"];
  }

  /// UPLOAD VIDEO (CHUNK + ADD)
  static Future<Map<String, dynamic>> uploadVideoWithProgress({
    required int categoryId,
    required String title,
    required String description,
    required File video,
    required File thumbnail,
    required Function(double) onProgress,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    /// STEP 1: Upload video chunk
    var chunkRequest = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/gym/videos/upload-chunk"),
    );

    chunkRequest.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    });

    chunkRequest.files.add(
      await http.MultipartFile.fromPath(
        "file",
        video.path,
      ),
    );

    var chunkResponse = await chunkRequest.send();
    var chunkRes = await http.Response.fromStream(chunkResponse);

    print("UPLOAD CHUNK RESPONSE: ${chunkRes.body}");

    final chunkData = jsonDecode(chunkRes.body);

    if (chunkData["success"] != true) {
      throw Exception("Video upload failed");
    }

    String tempPath = chunkData["temporary_path"];

    /// STEP 2: Add video
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/gym/videos/add"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["category_id"] = categoryId.toString();
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["temporary_path"] = tempPath;

    request.files.add(
      await http.MultipartFile.fromPath(
        "thumbnail",
        thumbnail.path,
      ),
    );

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    print("ADD VIDEO RESPONSE: ${res.body}");

    return jsonDecode(res.body);
  }

  static Future deleteVideo(int id) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.delete(
      Uri.parse("$baseUrl/gym/videos/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    return jsonDecode(res.body);
  }
  static Future updateVideo({
    required int videoId,
    required int categoryId,
    required String title,
    required String description,
    String? temporaryPath,
    File? thumbnail,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/gym/videos/update/$videoId"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    });

    request.fields["category_id"] = categoryId.toString();
    request.fields["title"] = title;
    request.fields["description"] = description;

    if (temporaryPath != null) {
      request.fields["temporary_path"] = temporaryPath;
    }

    if (thumbnail != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "thumbnail",
          thumbnail.path,
        ),
      );
    }

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    return jsonDecode(res.body);
  }

  static Future<List> getExerciseMaster() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/exercise-master"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(res.body);

    return data["data"];
  }

  static Future<Map> verifyCheckin({
    required String token,

  }) async {

    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/gym/verify-checkin"),
      headers: {
        "Authorization": "Bearer $auth",
        "Accept": "application/json"
      },
      body: {
        "token": token,

      },
    );

    return jsonDecode(res.body);
  }

  /// TOGGLE GYM STATUS
  static Future<Map> toggleGymStatus() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/gym/toggle-status"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    return jsonDecode(res.body);
  }
  static Future<List> getMembers() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/gym/members"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(res.body);

    return data["data"];
  }



  /// LOGOUT
  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      await prefs.clear();
      return true;
    } else {
      return false;
    }
  }


  // =============================
  // LIVE USERS
  // =============================

  static Future<List> getLiveUsers() async {

    final res = await http.get(
      Uri.parse("$baseUrl/gym/live-users"),
      headers: await headers(),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      return data["users"];
    }

    return [];
  }

  // =============================
  // CHECKOUT USER
  // =============================

  static Future<Map> checkOutUser(int attendanceId) async {

    final res = await http.post(
      Uri.parse("$baseUrl/gym/check-out/$attendanceId"),
      headers: await headers(),
    );

    return jsonDecode(res.body);
  }


  /// GET EQUIPMENT MASTER
  static Future<List> getEquipmentMaster() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/equipment/master"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      return data["data"];
    }

    return [];
  }

  /// GET GYM EQUIPMENT
  static Future<List> getEquipment() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/equipment"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      return data["data"];
    }

    return [];
  }

  /// ADD EQUIPMENT
  static Future addEquipment({
    required int equipmentId,
    required int quantity,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/equipment"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "equipment_master_id": equipmentId.toString(),
        "quantity": quantity.toString(),
      },
    );

    return jsonDecode(response.body);
  }

  /// UPDATE EQUIPMENT
  static Future updateEquipment({
    required int id,
    required int equipmentId,
    required int quantity,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/equipment/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "equipment_master_id": equipmentId.toString(),
        "quantity": quantity.toString(),
      },
    );

    return jsonDecode(response.body);
  }

  /// DELETE EQUIPMENT
  static Future deleteEquipment(int id) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/equipment/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    return jsonDecode(response.body);
  }

  /// =============================
  /// GET ALERT LIST
  /// =============================

  static Future<List> getAlerts() async {

    final res = await http.get(
      Uri.parse("$baseUrl/gym/alert"),
      headers: await headers(),
    );

    print("ALERT LIST STATUS: ${res.statusCode}");
    print("ALERT LIST BODY: ${res.body}");

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      return data["data"];
    }

    return [];
  }

  /// =============================
  /// ADD ALERT
  /// =============================

  static Future<Map> addAlert({
    required String title,
    required String message,
    required String expiresAt,
  }) async {

    final res = await http.post(
      Uri.parse("$baseUrl/gym/alert"),
      headers: await headers(),
      body: {
        "title": title,
        "message": message,
        "expires_at": expiresAt,
      },
    );

    print("ALERT STATUS: ${res.statusCode}");
    print("ALERT BODY: ${res.body}");

    return jsonDecode(res.body);
  }

 // =============================
  // ATTENDANCE HISTORY
  // =============================

  static Future<List> getAttendanceHistory({
    String? from,
    String? to,
  }) async {

    final res = await http.post(
      Uri.parse("$baseUrl/gym/attendance-history"),
      headers: await headers(),
      body: {
        if (from != null) "from": from,
        if (to != null) "to": to,
      },
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      return data["data"];
    }

    return [];
  }

}
