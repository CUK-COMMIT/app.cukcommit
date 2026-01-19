// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static final FirebaseFirestore _db = FirebaseFirestore.instance;

//   static User? get currentUser => _auth.currentUser;

//   static Future<String?> getIdToken() async {
//     return await _auth.currentUser?.getIdToken();
//   }

//   // ============================================================
//   // Firestore helper (common for all auth methods)
//   // ============================================================
//   static Future<void> _ensureUserDoc({
//     required User user,
//     String? name,
//   }) async {
//     final docRef = _db.collection("users").doc(user.uid);

//     final snap = await docRef.get();
//     final existing = snap.data();

//     final payload = <String, dynamic>{
//       "uid": user.uid,
//       "name": name ?? user.displayName ?? existing?["name"] ?? "",
//       "email": user.email ?? existing?["email"] ?? "",
//       "photoUrl": user.photoURL ?? existing?["photoUrl"],
//       "emailVerified": user.emailVerified,
//       "provider": user.providerData.isNotEmpty
//           ? user.providerData.first.providerId
//           : existing?["provider"] ?? "unknown",
//       "lastLoginAt": FieldValue.serverTimestamp(),
//     };

//     if (!snap.exists) {
//       await docRef.set({
//         ...payload,
//         "isProfileCompleted": false,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//     } else {
//       await docRef.update(payload);
//     }
//   }

//   // ============================================================
//   // Email/Password register
//   // ============================================================
//   static Future<UserCredential> register({
//     required String email,
//     required String password,
//     required String name,
//   }) async {
//     final cred = await _auth.createUserWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final user = cred.user;
//     if (user == null) throw Exception("User is null after registration");

//     await user.updateDisplayName(name.trim());

//     // send verification email
//     await user.sendEmailVerification();

//     // create Firestore profile
//     await _db.collection("users").doc(user.uid).set({
//       "uid": user.uid,
//       "name": name.trim(),
//       "email": email.trim(),
//       "photoUrl": user.photoURL,
//       "isProfileCompleted": false,
//       "emailVerified": user.emailVerified,
//       "provider": "password",
//       "createdAt": FieldValue.serverTimestamp(),
//       "lastLoginAt": FieldValue.serverTimestamp(),
//     });

//     return cred;
//   }

//   // ============================================================
//   // Email/Password login (blocks unverified users)
//   // ============================================================
//   static Future<UserCredential> login({
//     required String email,
//     required String password,
//   }) async {
//     final cred = await _auth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final user = cred.user;
//     if (user == null) throw Exception("User is null after login");

//     await user.reload();
//     final refreshedUser = _auth.currentUser;
//     if (refreshedUser == null) throw Exception("User is null after reload");

//     if (!refreshedUser.emailVerified) {
//       await _auth.signOut();
//       throw Exception("Email not verified. Please verify your email first.");
//     }

//     await _db.collection("users").doc(refreshedUser.uid).update({
//       "emailVerified": true,
//       "emailVerifiedAt": FieldValue.serverTimestamp(),
//       "lastLoginAt": FieldValue.serverTimestamp(),
//     });

//     return cred;
//   }

//   // ============================================================
//   // Google Login / Register (same flow)
//   // ============================================================
//   static Future<UserCredential> signInWithGoogle() async {
//     // show account picker reliably
//     final googleSignIn = GoogleSignIn(scopes: ["email"]);
//     await googleSignIn.disconnect().catchError((_) {});

//     final googleUser = await googleSignIn.signIn();
//     if (googleUser == null) {
//       throw Exception("Google Sign-In cancelled");
//     }

//     final googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCred = await _auth.signInWithCredential(credential);

//     final user = userCred.user;
//     if (user == null) throw Exception("User is null after Google sign-in");

//     await _ensureUserDoc(user: user, name: user.displayName);

//     return userCred;
//   }

//   // ============================================================
//   // Apple Login (future implementation placeholder)
//   // ============================================================
//   /*
//   static Future<UserCredential> signInWithApple() async {
//     // Future steps:
//     // 1) Enable Apple provider in Firebase Console
//     // 2) Apple Developer: create Services ID, Key, configure Sign in with Apple
//     // 3) Add iOS capability + configure URL schemes
//     // 4) Use sign_in_with_apple package to get credential
//     // 5) Convert to Firebase OAuthCredential and signInWithCredential
//     //
//     // final credential = OAuthProvider("apple.com").credential(
//     //   idToken: ...,
//     //   accessToken: ...,
//     // );
//     // final userCred = await _auth.signInWithCredential(credential);
//     // await _ensureUserDoc(user: userCred.user!, name: userCred.user!.displayName);
//     // return userCred;

//     throw UnimplementedError("Apple Sign-In not implemented yet");
//   }
//   */

//   // ============================================================
//   // resend verification email
//   // ============================================================
//   static Future<void> resendEmailVerification() async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception("No user logged in");

//     await user.reload();
//     final refreshedUser = _auth.currentUser;

//     if (refreshedUser == null) throw Exception("No user after reload");
//     if (refreshedUser.emailVerified) return;

//     await refreshedUser.sendEmailVerification();
//   }

//   // checks current verification status
//   static Future<bool> isEmailVerified() async {
//     final user = _auth.currentUser;
//     if (user == null) return false;

//     await user.reload();
//     return _auth.currentUser?.emailVerified ?? false;
//   }

//   // logout
//   static Future<void> logout() async {
//     await GoogleSignIn().signOut().catchError((_) {});
//     await _auth.signOut();
//   }
// }
