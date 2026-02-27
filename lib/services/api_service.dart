// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api';
  static String? _token;
  static String? _userId;
  static String? _userType;
  static String? _userName;
  static String? _userEmail;
  static String? _userPhone;

  // Initialize with saved data
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userType = prefs.getString('userType');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userPhone = prefs.getString('userPhone');
  }

  // Get token method
  static Future<String?> getToken() async {
    await init(); // Ensure data is loaded
    return _token;
  }

  static void setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static void setUserId(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static void setUserType(String userType) async {
    _userType = userType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  static void setUserName(String userName) async {
    _userName = userName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  static void setUserEmail(String userEmail) async {
    _userEmail = userEmail;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', userEmail);
  }

  static void setUserPhone(String userPhone) async {
    _userPhone = userPhone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', userPhone);
  }

  static String? getUserId() {
    return _userId;
  }

  static String? getUserType() {
    return _userType;
  }

  static String? getUserName() {
    return _userName;
  }

  static String? getUserEmail() {
    return _userEmail;
  }

  static String? getUserPhone() {
    return _userPhone;
  }

  static Future<Map<String, String>> _getHeaders() async {
    await init(); // Ensure data is loaded
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Update user profile method
  static Future<dynamic> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      final responseData = _handleResponse(response);

      // Update local storage with new data
      if (profileData.containsKey('name')) {
        setUserName(profileData['name']);
      }
      if (profileData.containsKey('phone')) {
        setUserPhone(profileData['phone']);
      }
      if (profileData.containsKey('email')) {
        setUserEmail(profileData['email']);
      }

      return responseData;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  static Future<dynamic> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    String? qualification,
    String? shelterName,
    String? shelterAddress,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'userType': userType,
        if (userType == 'Veterinarian') 'qualification': qualification,
        if (userType == 'Animal Shelter') ...{
          'shelterName': shelterName,
          'shelterAddress': shelterAddress,
        },
      }),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> loginUser({
    required String email,
    required String password,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = _handleResponse(response);

    // Store user data after successful login
    if (responseData['token'] != null) {
      setToken(responseData['token']);
      setUserId(responseData['userId'] ?? '');
      setUserType(responseData['userType'] ?? 'Pet Owner');

      // Store all user information if available in login response
      if (responseData['name'] != null) {
        setUserName(responseData['name']);
      }
      if (responseData['email'] != null) {
        setUserEmail(responseData['email']);
      }
      if (responseData['phone'] != null) {
        setUserPhone(responseData['phone']);
      }
    }

    return responseData;
  }

  static Future<dynamic> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: headers,
      );

      final responseData = _handleResponse(response);

      // If profile endpoint returns valid data, store all user information
      if (responseData != null && responseData.containsKey('id')) {
        // Store all user data in shared preferences
        if (responseData.containsKey('name')) {
          setUserName(responseData['name']);
        }
        if (responseData.containsKey('email')) {
          setUserEmail(responseData['email']);
        }
        if (responseData.containsKey('phone')) {
          setUserPhone(responseData['phone']);
        }
        if (responseData.containsKey('userType')) {
          setUserType(responseData['userType']);
        }

        return responseData;
      }

      // If profile endpoint returns empty or invalid data, try using stored user data
      if (_userId != null && _userType != null) {
        return {
          'name': _userName ?? 'User',
          'email': _userEmail,
          'phone': _userPhone,
          'id': _userId,
          'userType': _userType,
        };
      }

      return {
        'name': 'User',
        'email': _userEmail,
        'phone': _userPhone,
        'id': _userId,
        'userType': _userType,
      };
    } catch (e) {
      // If profile endpoint fails, return stored user data as fallback
      if (_userId != null && _userType != null) {
        return {
          'name': _userName ?? 'User',
          'email': _userEmail,
          'phone': _userPhone,
          'id': _userId,
          'userType': _userType,
        };
      }
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  // Animal Shelter specific API methods
  static Future<dynamic> getShelterPets() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/shelter/pets'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> addShelterPet(Map<String, dynamic> petData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/shelter/pets'),
      headers: headers,
      body: jsonEncode(petData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getAdoptionRequests() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/shelter/adoption-requests'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> updateAdoptionRequestStatus(
    String requestId,
    String status,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/shelter/adoption-requests/$requestId'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getSuccessStories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/shelter/success-stories'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getSuccessStoriesByShelter(String shelterId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/success-stories/shelter/$shelterId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> addSuccessStory(Map<String, dynamic> storyData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/shelter/success-stories'),
      headers: headers,
      body: jsonEncode(storyData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getVolunteerContacts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/shelter/volunteers'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> addVolunteerContact(
    Map<String, dynamic> volunteerData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/shelter/volunteers'),
      headers: headers,
      body: jsonEncode(volunteerData),
    );

    return _handleResponse(response);
  }

  // Common methods for all user types
  static Future<dynamic> getPets() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/pets'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> createPet(Map<String, dynamic> petData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/pets'),
      headers: headers,
      body: jsonEncode(petData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getHealthRecords(String petId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/health?petId=$petId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> createHealthRecord(
    Map<String, dynamic> recordData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/health'),
      headers: headers,
      body: jsonEncode(recordData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getAppointments() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/appointments'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/appointments'),
      headers: headers,
      body: jsonEncode(appointmentData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> updateAppointment(
    String appointmentId,
    Map<String, dynamic> appointmentData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/appointments/$appointmentId'),
      headers: headers,
      body: jsonEncode(appointmentData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> deleteAppointment(String appointmentId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/appointments/$appointmentId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> updatePet(
    String petId,
    Map<String, dynamic> petData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/pets/$petId'),
      headers: headers,
      body: jsonEncode(petData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> deletePet(String petId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/pets/$petId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> updateHealthRecord(
    String recordId,
    Map<String, dynamic> recordData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/health/$recordId'),
      headers: headers,
      body: jsonEncode(recordData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> deleteHealthRecord(String recordId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/health/$recordId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Veterinarian specific methods
  static Future<dynamic> getVeterinarians() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/veterinarians'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getAvailableVeterinarians(
    String date,
    String time,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/veterinarian-availability/available/$date/$time'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> setVeterinarianAvailability(
    Map<String, dynamic> availabilityData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/veterinarian-availability'),
      headers: headers,
      body: jsonEncode(availabilityData),
    );

    return _handleResponse(response);
  }

  // Adoption request methods
  static Future<dynamic> createAdoptionRequest(
    Map<String, dynamic> requestData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/adoption-requests'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getAdoptionRequestsByShelter(String shelterId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/adoption-requests/shelter/$shelterId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> getAdoptionRequestsByUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/adoption-requests/user/$userId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Success stories methods
  static Future<dynamic> createSuccessStory(
    Map<String, dynamic> storyData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/success-stories'),
      headers: headers,
      body: jsonEncode(storyData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> updateSuccessStory(
    String storyId,
    Map<String, dynamic> storyData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/success-stories/$storyId'),
      headers: headers,
      body: jsonEncode(storyData),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> deleteSuccessStory(String storyId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/success-stories/$storyId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {'message': 'Success'};
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to load data: ${response.statusCode}',
        );
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  // Logout method to clear stored data
  static Future<void> logout() async {
    _token = null;
    _userId = null;
    _userType = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userType');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
  }

  // Add this method to check if user is logged in
  static Future<bool> isLoggedIn() async {
    await init();
    return _token != null;
  }

  // Refresh user data from server
  static Future<void> refreshUserData() async {
    try {
      final profileData = await getUserProfile();
      if (profileData != null) {
        setUserName(profileData['name'] ?? '');
        setUserEmail(profileData['email'] ?? '');
        setUserPhone(profileData['phone'] ?? '');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}
