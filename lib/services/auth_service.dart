import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/student_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Cloudinary Configuration ──
  final _cloudinary = CloudinaryPublic('dutsquswv', 'heaz0p48', cache: false);

  // ── Get Current User ──
  User? get currentUser => _auth.currentUser;

  // ── Auth State Stream ──
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── 1. Login Method ──
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed. Please check your credentials.';
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // ── 1.1 Google Sign-In Method with Domain Restriction & Test Email Whitelist ──
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      // 5. Domain restriction check (@da.edu.pk) with Debug Mode & Test Email Whitelist bypass
      if (user != null && user.email != null) {
        bool isOfficialDomain = user.email!.endsWith('@da.edu.pk');

        // Aapki allowed test emails ki list
        List<String> allowedTestEmails = ['shahzaib.safdar.ch@gmail.com'];

        bool isTestEmail = allowedTestEmails.contains(user.email);

        // Agar official domain nahi hai, test email bhi nahi hai, aur app debug mode mein bhi nahi hai tab access deny karein
        if (!isOfficialDomain && !isTestEmail && !kDebugMode) {
          await _auth.signOut();
          await GoogleSignIn().signOut();
          throw 'Access denied. Please use your official university email (@da.edu.pk).';
        }

        // 6. Check if student document exists in Firestore, if not create a basic one
        final docRef = _firestore.collection('students').doc(user.uid);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          await docRef.set({
            'id': user.uid,
            'fullName': user.displayName ?? 'Student',
            'studentId': '',
            'department': '',
            'semester': '',
            'email': user.email!,
            'phone': '',
            'profilePicture': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Google Sign-In failed.';
    } catch (e) {
      throw e.toString();
    }
  }

  // ── 2. Register Student Method ──
  Future<void> registerStudent({
    required String fullName,
    required String studentId,
    required String department,
    required String semester,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Create User in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save complete details to Firestore
      if (credential.user != null) {
        await _firestore.collection('students').doc(credential.user!.uid).set({
          'id': credential.user!.uid,
          'fullName': fullName,
          'studentId': studentId,
          'department': department,
          'semester': semester,
          'email': email,
          'phone': phone,
          'profilePicture': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Immediately Sign Out so user is forced to Login
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration failed. Please try again.';
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // ── 3. Send Password Reset Email ──
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send reset email.';
    } catch (e) {
      throw e.toString();
    }
  }

  // ── 4. Change Password ──
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw 'No user is currently logged in.';
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to change password.';
    } catch (e) {
      throw e.toString();
    }
  }

  // ── 5. Upload Profile Picture to Cloudinary ──
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'User not logged in.';

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_pictures',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      String imageUrl = response.secureUrl;

      await _firestore.collection('students').doc(user.uid).update({
        'profilePicture': imageUrl,
      });

      return imageUrl;
    } on CloudinaryException catch (e) {
      throw 'Cloudinary Error: ${e.message}';
    } catch (e) {
      throw 'Failed to upload image: ${e.toString()}';
    }
  }

  // ── 6. Remove Profile Picture ──
  Future<void> removeProfilePicture() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'User not logged in.';

      await _firestore.collection('students').doc(user.uid).update({
        'profilePicture': '',
      });
    } catch (e) {
      throw 'Failed to remove profile picture: ${e.toString()}';
    }
  }

  // ── 7. Update Student Profile ──
  Future<void> updateStudentProfile({
    required String fullName,
    required String department,
    required String semester,
    required String phone,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'User not logged in.';

      await _firestore.collection('students').doc(user.uid).update({
        'fullName': fullName,
        'department': department,
        'semester': semester,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update profile: ${e.toString()}';
    }
  }

  // ── 8. Logout Method ──
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // ── 9. Student Profile Stream ──
  Stream<StudentModel?> studentProfileStream(String uid) {
    return _firestore.collection('students').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return StudentModel.fromMap(data);
      }
      return null;
    });
  }
}
