import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/chat.dart';
import '../model/m_user.dart';
import '../model/message.dart';

class FirestoreService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirestoreService _firestoreService =
  FirestoreService._internal();

  FirestoreService._internal();

  factory FirestoreService() {
    return _firestoreService;
  }

  static get firestoreService => _firestoreService;

  Future<void> addUserToFirestore(MUser mUser) {
    final userCollectionRef = _firestore.collection('users');
    return userCollectionRef
        .doc(mUser.userId)
        .set(mUser.toJson(), SetOptions(merge: true))
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserWithDocumentId(
      {required String documentId}) {
    final userCollectionRef = _firestore.collection('users');
    Future<DocumentSnapshot<Map<String, dynamic>>> getUser =
    userCollectionRef.doc(documentId).get();
    return getUser;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getInitialUsers() async {
    Future<List<QueryDocumentSnapshot<Object?>>> queryList = _firestore
        .collection('users')
        .orderBy("displayName", descending: false)
        .limit(8)
        .get()
        .then(
          (QuerySnapshot querySnapshot) {
        return querySnapshot.docs;
      },
      onError: (e) => print("Error completing: $e"),
    );
    return queryList;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getMoreUsers(MUser lastUser) {
    Future<List<QueryDocumentSnapshot<Object?>>> queryList = _firestore
        .collection('users')
        .orderBy("displayName", descending: false)
        .startAfter([lastUser.displayName])
        .limit(7)
        .get()
        .then(
          (QuerySnapshot querySnapshot) {
        return querySnapshot.docs;
      },
      onError: (e) => print("Error completing: $e"),
    );
    return queryList;
  }

  recordToSessionOwnerFirestore(
      {required MUser sessionOwner,
        required MUser receiverUser,
        required Message message,
        required CollectionReference<Map<String, dynamic>> dialogCollectionRef}) {
    // Once mesaji gonderene kaydetcem
    return dialogCollectionRef
        .doc("${sessionOwner.userId}--${receiverUser.userId}")
        .collection("messages")
        .doc()
        .set(message.toJson(), SetOptions(merge: true))
        .then((value) => print("Message Added"))
        .catchError((error) => print("Failed to add message: $error"));
  }

  _recordToSessionOwnerChat(
      {required Chat chat,
        required MUser receiverUser,
        required MUser sessionOwner,
        required CollectionReference<Map<String, dynamic>> dialogCollectionRef}) {
    return dialogCollectionRef
        .doc("${sessionOwner.userId}--${receiverUser.userId}")
        .set(chat.toJson(), SetOptions(merge: true))
        .then((value) => print("Chat Added"))
        .catchError((error) => print("Failed to add chat: $error"));
  }

  _recordToReceiverUserChat(
      {required Chat chat,
        required MUser receiverUser,
        required MUser sessionOwner,
        required CollectionReference<Map<String, dynamic>> dialogCollectionRef}) {
    return dialogCollectionRef
        .doc("${receiverUser.userId}--${sessionOwner.userId}")
        .set(chat.toJson(), SetOptions(merge: true))
        .then((value) => print("Chat Added"))
        .catchError((error) => print("Failed to add chat: $error"));
  }

  recordToReceiverUserFirestore(
      {required MUser receiverUser,
        required MUser sessionOwner,
        required Message message,
        required CollectionReference<Map<String, dynamic>> dialogCollectionRef}) {
    Message updatedMessage = message;
    updatedMessage.fromMe = false;

    /// Daha sonra benden mi alanini degistir karsi taraf icin kaydet
    return dialogCollectionRef
        .doc("${receiverUser.userId}--${sessionOwner.userId}")
        .collection("messages")
        .doc()
        .set(updatedMessage.toJson(), SetOptions(merge: true))
        .then((value) => print("Message Added"))
        .catchError((error) => print("Failed to add message: $error"));
  }

  addMessageToFirestore(
      {required MUser receiverUser,
        required MUser sessionOwner,
        required Message message}) {
    final dialogCollectionRef = _firestore.collection('dialog');
    recordToSessionOwnerFirestore(
        sessionOwner: sessionOwner,
        receiverUser: receiverUser,
        message: message,
        dialogCollectionRef: dialogCollectionRef);
    recordToReceiverUserFirestore(
        receiverUser: receiverUser,
        sessionOwner: sessionOwner,
        message: message,
        dialogCollectionRef: dialogCollectionRef);

    /// Chat kendime kayit
    Chat chat = Chat(
        sessionOwnerId: sessionOwner.userId!,
        receiverUserId: receiverUser.userId!,
        receiverDisplayName: receiverUser.displayName!,
        lastMessage: message.content,
        createdTime: message.createdTime,
        receiverPhotoUrl: receiverUser.photoUrl!,
        fromMe: true);

    _recordToSessionOwnerChat(
        chat: chat,
        receiverUser: receiverUser,
        sessionOwner: sessionOwner,
        dialogCollectionRef: dialogCollectionRef);

    /// Chat nesnesinde degisilik yap karsiya kayit at
    Chat updatedChat = Chat(
        sessionOwnerId: receiverUser.userId!,
        receiverUserId: sessionOwner.userId!,
        receiverDisplayName: sessionOwner.displayName!,
        lastMessage: message.content,
        createdTime: message.createdTime,
        receiverPhotoUrl: sessionOwner.photoUrl!,
        fromMe: false);

    _recordToReceiverUserChat(
        chat: updatedChat,
        receiverUser: receiverUser,
        sessionOwner: sessionOwner,
        dialogCollectionRef: dialogCollectionRef);
  }

  Future<void> updatePhotoUrl(
      {required String userId, required String newPhotoUrl}) {
    CollectionReference userCollectionRef = _firestore.collection('users');
    return userCollectionRef
        .doc(userId)
        .update({"photoUrl": newPhotoUrl})
        .then((value) => print("User Photo Url Update Edildi"))
        .catchError(
            (error) => print("Failed to update user photo url: $error"));
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllChat(
      {required String sessionOwnerId}) {
    Future<QuerySnapshot<Map<String, dynamic>>> allChat = _firestore
        .collection('dialog')
        .where("sessionOwnerId", isEqualTo: sessionOwnerId)
        .get();
    return allChat;
  }

  Stream<QuerySnapshot<Object?>> getAllMessages(
      {required MUser sessionOwner, required MUser receiverUser}) {
    final Stream<QuerySnapshot> _dialogStream = _firestore
        .collection('dialog')
        .doc("${sessionOwner.userId}--${receiverUser.userId}")
        .collection("messages")
        .orderBy("createdTime", descending: true)
        .snapshots();
    return _dialogStream;
  }

  Future<void> saveTokenToDatabase(String token, String userId) async {
    await _firestore.collection('tokens').doc(userId).set({
      'token': "$token",
    });
    print("Token firebase");
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTokenFromDatabase(
      {required userId}) {
    final Future<DocumentSnapshot<Map<String, dynamic>>> _token =
    _firestore.collection('tokens').doc(userId).get();
    return _token;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getInitialMessages(
      {required MUser sessionOwner, required MUser receiverUser}) {
    Future<List<QueryDocumentSnapshot<Object?>>> queryList = _firestore
        .collection('dialog')
        .doc("${sessionOwner.userId}--${receiverUser.userId}")
        .collection("messages")
        .orderBy("createdTime", descending: true)
        .limit(9)
        .get()
        .then(
          (QuerySnapshot querySnapshot) {
        return querySnapshot.docs;
      },
      onError: (e) => print("Error completing: $e"),
    );
    return queryList;
  }

  Future<void> deleteUserFromFirestore(User user) async {
    try {
      DocumentReference _documentReference =
      await _firestore.collection('users').doc(user.uid);
      await _documentReference.delete();
    } catch (error) {
      print(error);
    }
  }

  // New method for updating a specific field
  Future<void> updateUserField({
    required String userId,
    required String field,
    required dynamic value,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
      });
      print("User field updated: $field");
    } catch (e) {
      print("Failed to update user field: $e");
    }
  }

  // Methods for managing occupations
  Future<void> saveOccupation(String userId, Map<String, dynamic> occupation) async {
    try {
      await updateUserField(
          userId: userId,
          field: 'occupations',
          value: FieldValue.arrayUnion([occupation])
      );
      print("Occupation saved");
    } catch (e) {
      print('Error saving occupation: $e');
    }
  }

  Future<void> deleteOccupation(String userId, Map<String, dynamic> occupation) async {
    try {
      await updateUserField(
          userId: userId,
          field: 'occupations',
          value: FieldValue.arrayRemove([occupation])
      );
      print("Occupation deleted");
    } catch (e) {
      print('Error deleting occupation: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOccupations(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await getUserWithDocumentId(documentId: userId);
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['occupations'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting occupations: $e');
      return [];
    }
  }
}
