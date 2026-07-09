import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/office_model.dart';

class OfficeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _docPath = 'settings/office';

  Future<OfficeModel?> getOffice() async {
    final doc = await _firestore.doc(_docPath).get();
    if (!doc.exists || doc.data() == null) return null;
    return OfficeModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateOffice(OfficeModel office) async {
    await _firestore.doc(_docPath).set(office.toMap());
  }
}