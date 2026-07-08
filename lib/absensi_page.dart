import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  // Mengarahkan ke tabel/path 'absensi' di Firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("absensi");

  // Controller untuk input form
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  String _status = 'Hadir';

  // Fungsi untuk menampilkan Bottom Sheet (Form Create & Update)
  void _showForm(BuildContext context, [String? key, Map? data]) {
    // Jika 'data' ada isinya, berarti ini Update. Jika kosong, berarti Create.
    if (data != null) {
      _namaController.text = data['nama'];
      _radiusController.text = data['radius_meter'].toString();
      _status = data['status'] ?? 'Hadir';
    } else {
      _namaController.clear();
      _radiusController.clear();
      _status = 'Hadir';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16, left: 16, right: 16
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Karyawan'),
            ),
            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Radius (Meter)'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: ['Hadir', 'Pulang', 'Izin', 'Sakit'].map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _status = val!;
                });
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // CREATE (Jika key kosong)
                if (key == null) {
                  await _dbRef.push().set({
                    "nama": _namaController.text,
                    "status": _status,
                    "radius_meter": int.tryParse(_radiusController.text) ?? 0,
                    "waktu_absen": DateTime.now().toIso8601String(),
                  });
                } 
                // UPDATE (Jika key ada)
                else {
                  await _dbRef.child(key).update({
                    "nama": _namaController.text,
                    "status": _status,
                    "radius_meter": int.tryParse(_radiusController.text) ?? 0,
                  });
                }
                
                _namaController.clear();
                _radiusController.clear();
                if (mounted) Navigator.of(context).pop(); // Tutup form
              },
              child: Text(key == null ? 'Simpan Absen' : 'Update Data'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Fungsi DELETE
  void _deleteData(String key) async {
    await _dbRef.child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absensi TERA'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // READ: Menampilkan data secara Real-time
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
            Map data = snapshot.data!.snapshot.value as Map;
            List items = [];

            // Memasukkan Map dari Firebase ke dalam format List agar mudah di-build
            data.forEach((index, data) => items.add({"key": index, ...data}));
            
            // Urutkan data berdasarkan waktu terbaru
            items.sort((a, b) => (b['waktu_absen'] ?? '').compareTo(a['waktu_absen'] ?? ''));

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      items[index]['nama'] ?? 'Tanpa Nama',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Status: ${items[index]['status']} \nRadius: ${items[index]['radius_meter']} meter'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          // Panggil form dengan mengirim data (Update)
                          onPressed: () => _showForm(context, items[index]['key'], items[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          // Panggil fungsi delete berdasarkan key unik
                          onPressed: () => _deleteData(items[index]['key']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // Tampilan jika database kosong
          return const Center(child: Text('Belum ada data absensi.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Panggil form tanpa mengirim data (Create)
        onPressed: () => _showForm(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}