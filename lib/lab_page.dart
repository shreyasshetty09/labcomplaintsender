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
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        color: Colors.grey[200],
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
                decoration: InputDecoration(
                  labelText: 'Select Lab',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _instructorNameController,
                decoration: InputDecoration(
                  labelText: 'Instructor Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the instructor name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _instructorIdController,
                decoration: InputDecoration(
                  labelText: 'Instructor ID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the instructor ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _pcNoController,
                decoration: InputDecoration(
                  labelText: 'PC No',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the PC number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _complaintController,
                decoration: InputDecoration(
                  labelText: 'Complaint',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
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
                        content: Text('Complaint Submitted Successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
