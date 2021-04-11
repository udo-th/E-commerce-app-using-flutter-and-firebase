import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = new FlutterSecureStorage();
  final String sharedKey = 'sharedKey';
  final tokenKey = 'token';
  int statusCode;
  String msg;

  void createAndStoreJWTToken(String uid) async{
    var builder = new JWTBuilder();
    var token = builder
    ..expiresAt = new DateTime.now().add(new Duration(hours: 3))
    ..setClaim('data', {'uid': uid})
    ..getToken();

    var signer = new JWTHmacSha256Signer(sharedKey);
    var signedToken = builder.getSignedToken(signer);
    await _writeToken(signedToken.toString());
  }

  Future _writeToken(String token) async {
    if (!kIsWeb) {
      storage.write(key: tokenKey, value: token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, token);
    }
  }

  Future<String> readToken() async {
    if (!kIsWeb) {
      return await storage.read(key: tokenKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    }
  }

  Future _deleteToken() async {
    if (!kIsWeb) {
      await storage.delete(key: tokenKey);
    }else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.remove(tokenKey);
    }
  }


  String validateToken(String token){
    var signer = new JWTHmacSha256Signer(sharedKey);
    var decodedToken = new JWT.parse(token);
    if(decodedToken.verify(signer)){
      final parts = token.split('.');
      final payload = parts[1];
      final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
      final int expiry = jsonDecode(decoded)['exp']* 1000;
      final currentDate = DateTime.now().millisecondsSinceEpoch;
      if(currentDate > expiry){
        return null;
      }
      return  jsonDecode(decoded)['data']['uid'];
    }
    return null;
  }

  void logOut(context) async{
    await _deleteToken();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> login(userValues) async{
    String email = userValues['email'];
    String password = userValues['password'];

    await _auth.signInWithEmailAndPassword(email: email, password: password).then((dynamic user) async{
      final User currentUser = _auth.currentUser;
      final uid = currentUser.uid;

      createAndStoreJWTToken(uid);

      statusCode = 200;

    }).catchError((error){
      handleAuthErrors(error);
    });
  }

  Future<String> getUserId() async{
    var token = await storage.read(key: 'token');
    var uid = validateToken(token);
    return uid;
  }

  Future<void> signup(userValues) async{
    String email = userValues['email'];
    String password = userValues['password'];

    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((user){
      String uid = user.user.uid;
      _firestore.collection('users').add({
        'fullName': userValues['fullName'],
        'mobileNumber': userValues['mobileNumber'],
        'userId': uid
      });

      statusCode = 200;
    }).catchError((error){
      handleAuthErrors(error);
    });
  }

  void handleAuthErrors(error){
    String errorCode = error.code;
    switch(errorCode){
      case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          statusCode = 400;
          msg = "Email ID already existed";
        }
        break;
      case "ERROR_WRONG_PASSWORD":
        {
          statusCode = 400;
          msg = "Password is wrong";
        }
    }
  }

  String capitalizeName(String name){
    name = name[0].toUpperCase()+ name.substring(1);
    return name;
  }

  String userEmail(){
    var user = _auth.currentUser;
    return user.email;
  }

  Future<List> userWishlist() async{
    String uid = await getUserId();
    QuerySnapshot userRef = await _firestore.collection('users').where('userId',isEqualTo: uid).get();
    List <dynamic> wishlist = userRef.docs[0].data()['wishlist'];
    List userList = new List();
    for(String item in wishlist){
      Map<String, dynamic> temp = new Map();
      DocumentSnapshot productRef = await _firestore.collection('products').doc(item).get();
      temp['productName'] = productRef.data()['name'];
      temp['price'] = productRef.data()['price'];
      temp['image'] = productRef.data()['image'];
      temp['productId'] = productRef.id;
      userList.add(temp);
    }
    return userList;
  }

  Future<void> deleteUserWishlistItems(String productId) async{
    String uid = await getUserId();
    QuerySnapshot userRef = await _firestore.collection('users').where('userId',isEqualTo: uid).get();
    String documentId = userRef.docs[0].id;
    Map<String,dynamic> wishlist = userRef.docs[0].data();
    wishlist['wishlist'].remove(productId);

    await _firestore.collection('users').doc(documentId).update({
      'wishlist':wishlist['wishlist']
    });
  }
}

