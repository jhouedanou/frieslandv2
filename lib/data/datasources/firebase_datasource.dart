import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visite_model.dart';
import '../models/pdv_model.dart';
import '../../core/constants/app_constants.dart';

abstract class FirebaseDataSource {
  Future<void> createVisite(VisiteModel visite);
  Future<void> updateVisite(VisiteModel visite);
  Future<List<VisiteModel>> getVisites();
  Future<List<VisiteModel>> getVisitesByCommercial(String commercial);
  Stream<List<VisiteModel>> watchVisites();
  
  Future<void> createPDV(PDVModel pdv);
  Future<void> updatePDV(PDVModel pdv);
  Future<List<PDVModel>> getPDVs();
  Future<List<PDVModel>> getPDVsBySecteur(String secteur);
  Stream<List<PDVModel>> watchPDVs();
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseFirestore firestore;

  FirebaseDataSourceImpl({required this.firestore});

  @override
  Future<void> createVisite(VisiteModel visite) async {
    try {
      await firestore
          .collection(AppConstants.visitesCollection)
          .doc(visite.visiteId)
          .set(visite.toFirestore());
    } catch (e) {
      throw Exception('Failed to create visite: $e');
    }
  }

  @override
  Future<void> updateVisite(VisiteModel visite) async {
    try {
      await firestore
          .collection(AppConstants.visitesCollection)
          .doc(visite.visiteId)
          .update(visite.toFirestore());
    } catch (e) {
      throw Exception('Failed to update visite: $e');
    }
  }

  @override
  Future<List<VisiteModel>> getVisites() async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection(AppConstants.visitesCollection)
          .orderBy('date_visite', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VisiteModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get visites: $e');
    }
  }

  @override
  Future<List<VisiteModel>> getVisitesByCommercial(String commercial) async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection(AppConstants.visitesCollection)
          .where('commercial', isEqualTo: commercial)
          .orderBy('date_visite', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VisiteModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get visites by commercial: $e');
    }
  }

  @override
  Stream<List<VisiteModel>> watchVisites() {
    return firestore
        .collection(AppConstants.visitesCollection)
        .orderBy('date_visite', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VisiteModel.fromFirestore(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> createPDV(PDVModel pdv) async {
    try {
      await firestore
          .collection(AppConstants.pdvCollection)
          .doc(pdv.pdvId)
          .set(pdv.toFirestore());
    } catch (e) {
      throw Exception('Failed to create PDV: $e');
    }
  }

  @override
  Future<void> updatePDV(PDVModel pdv) async {
    try {
      await firestore
          .collection(AppConstants.pdvCollection)
          .doc(pdv.pdvId)
          .update(pdv.toFirestore());
    } catch (e) {
      throw Exception('Failed to update PDV: $e');
    }
  }

  @override
  Future<List<PDVModel>> getPDVs() async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection(AppConstants.pdvCollection)
          .orderBy('nom_pdv')
          .get();

      return snapshot.docs
          .map((doc) => PDVModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get PDVs: $e');
    }
  }

  @override
  Future<List<PDVModel>> getPDVsBySecteur(String secteur) async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection(AppConstants.pdvCollection)
          .where('secteur', isEqualTo: secteur)
          .orderBy('nom_pdv')
          .get();

      return snapshot.docs
          .map((doc) => PDVModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get PDVs by secteur: $e');
    }
  }

  @override
  Stream<List<PDVModel>> watchPDVs() {
    return firestore
        .collection(AppConstants.pdvCollection)
        .orderBy('nom_pdv')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PDVModel.fromFirestore(doc.data()))
          .toList();
    });
  }
}