import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../DATA MODELS/Child Model/Child Model.dart';
import 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChildCubit() : super(ChildInitial());

  Future<void> fetchChildren(String parentId) async {
    try {
      emit(ChildLoading());

      final snapshot = await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      final children = snapshot.docs
          .map((doc) => Child.fromMap(doc.data(), doc.id))
          .toList();

      emit(ChildLoaded(children));
    } catch (e) {
      emit(ChildError('Failed to fetch children: ${e.toString()}'));
    }
  }

  Future<void> addChild(String parentId, Child child) async {
    try {
      emit(ChildLoading());

      // Ensure parent doc exists
      await _firestore
          .collection('parents')
          .doc(parentId)
          .set({}, SetOptions(merge: true));

      await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .add(child.toMap());

      await fetchChildren(parentId);
    } catch (e) {
      emit(ChildError('Failed to add child: ${e.toString()}'));
    }
  }

  Future<void> deleteChild(String parentId, String childId) async {
    try {
      emit(ChildLoading());

      await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .delete();

      await fetchChildren(parentId);
    } catch (e) {
      emit(ChildError('Failed to delete child: ${e.toString()}'));
    }
  }

  Future<void> updateChild(String parentId, Child child) async {
    try {
      emit(ChildLoading());

      await _firestore
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(child.id)
          .update(child.toMap());

      await fetchChildren(parentId);
    } catch (e) {
      emit(ChildError('Failed to update child: ${e.toString()}'));
    }
  }
}
