import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = [];
  late Box<Medicine> _medicineBox;

  List<Medicine> get medicines {
    _medicines.sort((a, b) => a.time.compareTo(b.time));
    return _medicines;
  }

  Future<void> initHive() async {
    _medicineBox = await Hive.openBox<Medicine>('medicines');
    _medicines = _medicineBox.values.toList();
    NotificationService.updateMedicineList(_medicines);
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _medicineBox.add(medicine);
    _medicines = _medicineBox.values.toList();
    NotificationService.updateMedicineList(_medicines);
    notifyListeners();
  }

  Future<void> deleteMedicine(int index) async {
    await _medicineBox.deleteAt(index);
    _medicines = _medicineBox.values.toList();
    notifyListeners();
  }
}