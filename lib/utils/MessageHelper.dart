import 'package:http/http.dart' as http;

// Define your base URL as a constant

   String baseUrl = 'http://103.174.10.153:5040';

  // Method to send both WhatsApp and Email for Registration Successful
  Future<void> sendRegistrationSuccessful({
    required String name,
    required String role,
    required String companyName,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl = '$baseUrl/registration_successful/$name/$role/$companyName/$phoneNumber';
    final String emailUrl = '$baseUrl/send_registration_successful_email/$name/$role/$companyName/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Registration Approved
  Future<void> sendRegistrationApproved({
    required String name,
    required String role,
    required String companyName,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl = '$baseUrl/registration_approved/$name/$role/$companyName/$phoneNumber';
    final String emailUrl = '$baseUrl/send_registration_approved_email/$name/$role/$companyName/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Payment Confirmation
  Future<void> sendPaymentConfirmation({
    required String name,
    required String productServiceEvent,
    required String amount,
    required String transactionId,
    required String paymentDate,
    required String companyName,
    required String contactInformation,
    required String phoneNumber,
    required String email,
    required String attachmentFileName,
  }) async {
    final String whatsappUrl =
        '$baseUrl/payment_confirmation/$name/$productServiceEvent/$amount/$transactionId/$paymentDate/$companyName/$contactInformation/$phoneNumber';
    final String emailUrl =
        '$baseUrl/send_payment_confirmation_email/$name/$productServiceEvent/$amount/$transactionId/$paymentDate/$companyName/$contactInformation/$attachmentFileName/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Player Registration
  Future<void> sendPlayerRegistration({
    required String playerId,
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl = '$baseUrl/sportims/player_reg/$playerId/$name/$phoneNumber';
    final String emailUrl = '$baseUrl/send_club_registration_successful_email/$name/$playerId/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Player Approval
  Future<void> sendPlayerApproval({
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl = '$baseUrl/sportims/player_approval/$name/$phoneNumber';
    final String emailUrl = '$baseUrl/send_club_verification_successful_email/$name/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Event Registration Successful
  Future<void> sendEventRegistrationSuccessful({
    required String playerName,
    required String eventName,
    required String date,
    required String location,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl = '$baseUrl/sportims/event_reg/$playerName/$eventName/$date/$location/$phoneNumber';
    final String emailUrl = '$baseUrl/send_event_registration_successful_email/$playerName/$eventName/$date/$location/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Event Official Registration Successful
  Future<void> sendEventOfficialRegistrationSuccessful({
    required String name,
    required String role,
    required String eventName,
    required String eventDate,
    required String eventVenue,
    required String userName,
    required String password,
    required String companyName,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl =
        '$baseUrl/registration_successful_admin/$name/$role/$eventName/$userName/$password/$eventDate/$eventVenue/$companyName/$phoneNumber';
    final String emailUrl =
        '$baseUrl/send_registration_successful_admin_email/$name/$role/$eventName/$eventDate/$eventVenue/$userName/$password/$companyName/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Method to send both WhatsApp and Email for Event Official Registration Approved
  Future<void> sendEventOfficialRegistrationApproved({
    required String name,
    required String role,
    required String eventName,
    required String eventDate,
    required String eventVenue,
    required String userName,
    required String password,
    required String companyName,
    required String phoneNumber,
    required String email,
  }) async {
    final String whatsappUrl =
        '$baseUrl/registration_approved_admin/$name/$role/$eventName/$userName/$password/$eventDate/$eventVenue/$companyName/$phoneNumber';
    final String emailUrl =
        '$baseUrl/send_registration_approved_admin_email/$name/$role/$eventName/$userName/$password/$eventDate/$eventVenue/$companyName/$email';

    await _sendRequest(whatsappUrl);
    await _sendRequest(emailUrl);
  }

  // Private method to handle sending HTTP GET requests
  Future<void> _sendRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Request to $url successful');
      } else {
        print('Failed to send request to $url');
      }
    } catch (e) {
      print('Error occurred while sending request to $url: $e');
    }
  }

