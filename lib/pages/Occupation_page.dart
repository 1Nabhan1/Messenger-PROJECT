import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class OccupationPage extends StatefulWidget {
  const OccupationPage({super.key, required this.userId});
  final String userId;
  @override
  _OccupationPageState createState() => _OccupationPageState();
}

class _OccupationPageState extends State<OccupationPage> {
  final _occupationController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  final _firestoreService = FirestoreService();

  Future<void> _submitOccupation(String userId) async {
    final occupation = _occupationController.text;
    if (occupation.isNotEmpty) {
      final occupationData = {
        'occupation': occupation,
        'fromDate': _fromDate,
        'toDate': _toDate,
      };
      await _firestoreService.saveOccupation(userId, occupationData);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Occupation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fromDate == null
                        ? 'From Date'
                        : 'From Date: ${_fromDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectFromDate(context),
                  child: const Text('Select From Date'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _toDate == null
                        ? 'To Date'
                        : 'To Date: ${_toDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectToDate(context),
                  child: const Text('Select To Date'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _submitOccupation(widget.userId);
                // final occupation = _occupationController.text;
                // final fromDate = _fromDate;
                // final toDate = _toDate;
                // if (occupation.isNotEmpty && fromDate != null && toDate != null) {
                //   Navigator.pop(context, {
                //     'occupation': occupation,
                //     'fromDate': fromDate,
                //     'toDate': toDate,
                //   });
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Please fill all fields')),
                //   );
                // }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _occupationController.dispose();
    super.dispose();
  }
}
