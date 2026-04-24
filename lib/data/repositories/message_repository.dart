import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t5/data/models/message.dart';

class MessageRepository {
  
  Future <void> createMessage(String idEvent, Message message) async{
    await FirebaseFirestore.instance
        .collection('events')
        .doc(idEvent)
        .collection('messages')
        .add(message.toMap());
  }


  Stream<List<Message>> getEventMessages(String idEvent) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(idEvent)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }





}