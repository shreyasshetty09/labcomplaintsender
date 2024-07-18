import 'package:flutter/material.dart';
import 'firestore_service.dart';

class LabPage extends StatefulWidget {
  @override
  _LabPageState createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final TextEditingController _instructorNameController =
      TextEditingController();
  final TextEditingController _instructorIdController = TextEditingController();
  final TextEditingController _pcNoController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedLab = 'ML Lab';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Complaints'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedLab,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLab = newValue!;
                  });
                },
                items: <String>[
                  'ML Lab',
                  'DBMS Lab',
                  'Internet Lab',
                  'DS Lab',
                  'ADE/MCS Lab',
                  'CAD Lab'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Lab'),
              ),
              TextFormField(
                controller: _instructorNameController,
                decoration: InputDecoration(labelText: 'Instructor Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the instructor name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _instructorIdController,
                decoration: InputDecoration(labelText: 'Instructor ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the instructor ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pcNoController,
                decoration: InputDecoration(labelText: 'PC No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the PC number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _complaintController,
                decoration: InputDecoration(labelText: 'Complaint'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the complaint';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _firestoreService.addLabComplaint(
                      _selectedLab,
                      _instructorNameController.text,
                      _instructorIdController.text,
                      _pcNoController.text,
                      _complaintController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Complaint Submitted Successfully')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
