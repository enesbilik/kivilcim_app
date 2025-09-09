import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  static User? get currentUser => _auth.currentUser;
  
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email ile kayıt olma
  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Kayıt olma hatası: $e');
      return null;
    }
  }

  // Email ile giriş yapma
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Giriş yapma hatası: $e');
      return null;
    }
  }

  // Çıkış yapma
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore Methods
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get dailyComponentCollection => _firestore.collection('daily_component');

  // Kullanıcı bilgilerini kaydetme
  static Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(uid).set(userData);
    } catch (e) {
      print('Kullanıcı verisi kaydetme hatası: $e');
    }
  }

  // Kullanıcı bilgilerini getirme
  static Future<DocumentSnapshot> getUserData(String uid) async {
    return await usersCollection.doc(uid).get();
  }

  // Günlük veri çekme (bugünün tarihine göre)
  static Future<Map<String, dynamic>?> getDailyQuote() async {
    try {
      // Bugünün tarihini "dd.MM.yyyy" formatında oluştur
      final now = DateTime.now();
      final todayKey = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      
      // Tüm koleksiyonu çek
      final allDocs = await dailyComponentCollection.get();
      
      // Tüm dokümanları dolaş ve date alanını kontrol et
      for (var doc in allDocs.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['date'] != null) {
          final docDate = data['date'].toString();
          
          if (docDate == todayKey) {
            return data;
          }
        }
      }
      
      return null;
      
    } catch (e) {
      print('Günlük veri çekme hatası: $e');
      return null;
    }
  }


  // Storage Methods
  static Reference get storageRef => _storage.ref();

  // Dosya yükleme
  static Future<String> uploadFile(String path, Uint8List data) async {
    try {
      Reference ref = storageRef.child(path);
      UploadTask uploadTask = ref.putData(data);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      return '';
    }
  }
}
