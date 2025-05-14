import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialiser les paramètres
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logoapp'); // icône de notification

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Afficher la notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID
      title,
      body,
      notificationDetails,
    );
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "prjtrain-18dde",
      "private_key_id": "0556e0258c188dfc5d28859c90d6f3205860f1fa",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQChoxMn+q/pGx9c\njtaI0ldAWoB6eQogkj4q5D3YmZw8CY14PLbDPMgfKjLpDsOATMhmBK/ir6e0NCBT\ndO5onBpieXbsz5LiAfMnZkqSh/Hm9nf2sTYx8W0JcGxb4em22Q/PyWUMkUSvv8Ah\nXv3Ba1CuazmBpWPMzdo+vjsdUBb6P7C/DH1y1zGC12IesIu3F0RP/BYMpu720Le7\nCfd2PwZdXoOa/pHfLqk7A8Y/1kWt/I97/tyRVExGubzs6J6k0jhE507c6sPFU9cx\neOwicvSxVQQC4N5EBuq6RRoRGh5pYhBK+Edh48Seo+veysUkurfyexCdSmy2Odqd\ndRDpS8nNAgMBAAECggEACO1ZtD+lTLhVroC+wA6anjWxZVzp2TEtM6S99rMgh3Sr\n8Sasnb1YZyznOWsk6IvfwI9Z4H5SQpgOFgCTX0iJ24OjtMIPyyGPmqQ3Z6mQS8Yz\n4MvaTKlYcT5EjybmcoBsCLjx4V8Pk65Wj/FFY2lIKuNF/o9SIwBWjAMT1D4KutZI\nWO3Pa3h/G5hkxDzvuwHy4b5Br6yu3UWkiqf+Nyvparm2tc0pGXZiCfPXLeRjATcD\nE0rz06S4dlm32iwV0D7wlftQknUUjnF7nULqKGaiMct2ePyJGGJcNzG7r62sMmIb\nIish5f0JQRiv5f8MbI9gYCuibpwQw/mOAjKXJdbUUQKBgQDWZpiwL+wkyIOec/qB\nUjzEloCeFnJ3ssEO/2B8siBPDb0NYPoD8pN6ulP1Ni4x10XbuaPunvHcxuTiohBl\ni1Zuc19Wv16Bj47tlmij4GT2uepYTX35YAsILrGZ4u8/nn/wHbsL4qY89iEVc7Ar\nQfqPF2HGLd1I/+tcv68y/VZ+3QKBgQDA/6x4YDLret4sf2H6iBkR8xRCnwm9Duvt\nDqImmJEuMUAZiGLH3TBnBM/qwP4I9peoBsrznCRjpcx7GjgBV//husOnDjgNURup\nBWqU/FDGSs3B1PEE1EYnASaOICZpW/UAp5O22NlyXDgajmBlYCIUM0/BLeqL0wvH\numEQMgmvsQKBgQC8SBMUvrEBSHmVoEJAaUjmV0kSC6JwjbFPC2PffcozwlvgsOY+\nqztqjtEGSZNdv7AgmrFk7351JNGCWVJO6oN3safrFVnYK4sYCHtSVtAzf+dVro/P\nfNGTWPYsrwbt9rJh2qoVcPAOHxPEs/jktCdmm+EIWeS3o888fzVLcQERnQKBgQCi\nncsAkm3VI+3XqG0x30LgcOR9TeuytMPtNgtCYgLR3QWZfeVdae3Cn7dgocRqYPxf\nw3l10faHT8f/YZQW7cLYu7jnJX/tGI4p2Dp51i9pJNZBn96EpyeE7d9CmaxD0guZ\nxZkc05JEXZeYKKboRBvy0Vk9+CZMMkMWwt/N+ZtXwQKBgBeK5KZjoHun5WWLWqsz\nwz+2oTSCdGfAQHnIq4DuZdUahLkqMhM8xWOoHKGRVYDP43yRRknAzD7aSLW5bXsi\nHRZ/YR4+7LIx3RD9fH9FIFrwRmQiG0xOoqxBRw73p0bgbAQK/AED+X3jFMNjA799\nV2FtCpu/PXWJpcll9+7u7sWY\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@prjtrain-18dde.iam.gserviceaccount.com",
      "client_id": "104350477706209156152",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40prjtrain-18dde.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
      "priority": "high",
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client,
        );
    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
    String topic,
    String title,
    String body,
  ) async {
    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/prjtrain-18dde/messages:send';

    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> message = {
      "message": {
        "topic": topic,
        "notification": {"title": title, "body": body, "icon": "logoapp"},
        "android": {
          "notification": {
            "channel_id": "default",
            "tag": "notif_$timestamp", // unique tag to avoid replacement
          },
        },
        "data": {"route": "serviceScreen"},
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('✅ Notification envoyée avec succès');
    } else {
      print('❌ Échec de l’envoi : ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> savenotificationdatabase(String etat, msg) async {
    await FirebaseFirestore.instance.collection('notification').add({
      'etat': etat,
      'message': msg,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
