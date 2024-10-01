// caretakers_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaretakerListPage extends StatefulWidget {
  const CaretakerListPage({Key? key}) : super(key: key);

  @override
  _CaretakerListPageState createState() => _CaretakerListPageState();
}

class _CaretakerListPageState extends State<CaretakerListPage> {
  bool _isExpanded = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> _getCaretakers() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('caretakers')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Caretakers')),
        ),
        body: const Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretakers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCaretakers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching caretakers'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No caretaker found'));
          }

          var document = snapshot.data!.docs.first;
          var data = document.data()! as Map<String, dynamic>;
          String caretakerId = document.id;
          String name = data['name'] ?? 'No Name';
          String phone = data['phone'] ?? 'No Phone';
          String email = data['email'] ?? 'No Email';
          String specialist = data['specialist'] ?? 'No Data';
          String location = data['location'] ?? 'No Data';
          String description = data['description'] ?? 'No Description';
          String experience = data['expereince'] ?? 'No Data';

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var caretakerData = doc.data()! as Map<String, dynamic>;
              String cid = doc.id;
              String caretakerName = caretakerData['name'] ?? 'No Name';
              String caretakerPhone = caretakerData['phone'] ?? 'No Phone';
              String caretakerEmail = caretakerData['email'] ?? 'No Email';
              String caretakerLocation = caretakerData['location'] ?? 'No Data';
              String caretakerSpecialist =
                  caretakerData['specialist'] ?? 'No Data';
              String caretakerDescription =
                  caretakerData['description'] ?? 'No Data';
              String caretakerExperience =
                  caretakerData['experience'] ?? 'No Data';

              return CaretakerListItem(
                caretakerId: cid,
                name: caretakerName,
                phone: caretakerPhone,
                email: caretakerEmail,
                location: caretakerLocation,
                experience: caretakerExperience,
                specialist: caretakerSpecialist,
                description: caretakerDescription,
                isExpanded: _isExpanded,
                onExpandToggle: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                onVideoCall: () {
                  print('Video call with $caretakerName');
                },
                onText: () {
                  print('Text with $caretakerName');
                },
                onRemove: () {
                  _showRemoveConfirmation(context, cid, caretakerName);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: _getCaretakers(),
        builder: (context, snapshot) {
          bool hasCaretaker =
              snapshot.hasData && snapshot.data!.docs.isNotEmpty;
          return hasCaretaker
              ? Container()
              : FloatingActionButton(
                  onPressed: () {
                    _showAddCaretakerDialog(context);
                  },
                  child: const Icon(Icons.add),
                );
        },
      ),
    );
  }

  void _showRemoveConfirmation(
      BuildContext context, String caretakerId, String caretakerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Caretaker'),
          content: Text(
              'Are you sure you want to remove $caretakerName as your caretaker?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('caretakers')
                    .doc(caretakerId)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$caretakerName removed')),
                  );
                }).catchError((error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to remove caretaker: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCaretakerDialog(BuildContext context) {
    final TextEditingController _cidController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Caretaker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cidController,
                decoration:
                    const InputDecoration(labelText: 'Enter Caretaker ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () async {
                String cid = _cidController.text.trim();
                if (cid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an ID')),
                  );
                  return;
                }

                var caretakerSnapshot = await FirebaseFirestore.instance
                    .collection('caretakers')
                    .doc(cid)
                    .get();
                if (caretakerSnapshot.exists) {
                  var caretakerData = caretakerSnapshot.data()!;
                  String name = caretakerData['name'] ?? 'No Name';
                  String phone = caretakerData['phone'] ?? 'No Phone';
                  String email = caretakerData['email'] ?? 'No Email';
                  String location = caretakerData['location'] ?? 'No Data';
                  String experience = caretakerData['experience'] ?? 'No Data';
                  String specialist = caretakerData['specialist'] ?? 'No Data';
                  String description =
                      caretakerData['description'] ?? 'No Data';

                  var existingCaretaker = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('caretakers')
                      .doc(cid)
                      .get();

                  if (existingCaretaker.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Caretaker already added')),
                    );
                    Navigator.of(context).pop();
                    return;
                  }

                  Navigator.of(context).pop();

                  _showConfirmAddCaretakerDialog(
                      context, cid, name, phone, email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Caretaker not found')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmAddCaretakerDialog(BuildContext context, String cid,
      String name, String phone, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Add Caretaker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: $name', style: const TextStyle(fontSize: 16)),
              Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
              Text('Email: $email', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('caretakers')
                    .doc(cid)
                    .set({
                  'name': name,
                  'phone': phone,
                  'email': email,
                  'cid': cid,
                }).then((_) async {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name added as caretaker')),
                  );
                  await FirebaseFirestore.instance
                      .collection('caretakers')
                      .doc(cid)
                      .collection('users')
                      .doc(currentUser!.uid)
                      .set({
                    'name': currentUser!.displayName ?? 'No Name',
                    'email': currentUser!.email ?? 'No Email',
                  });
                }).catchError((error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add caretaker: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class CaretakerListItem extends StatelessWidget {
  final String caretakerId;
  final String name;
  final String phone;
  final String email;
  final String location;
  final String experience;
  final String specialist;
  final String description;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onVideoCall;
  final VoidCallback onText;
  final VoidCallback onRemove;

  const CaretakerListItem({
    Key? key,
    required this.caretakerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.experience,
    required this.specialist,
    required this.description,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onVideoCall,
    required this.onText,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5),
        ],
      ),
      child: InkWell(
        onTap: onExpandToggle,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onExpandToggle,
                    child: const Icon(Icons.more_vert,
                        size: 30, color: Colors.black),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Email: $email',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Phone: $phone',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Location: $location',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Expertise: $specialist',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Expereince: $experience',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Description: $description',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOptionIcon(
                          icon: Icons.video_call,
                          label: 'Video Call',
                          onTap: onVideoCall,
                        ),
                        _buildOptionIcon(
                          icon: Icons.message,
                          label: 'Chat',
                          onTap: onText,
                        ),
                        _buildOptionIcon(
                          icon: Icons.delete,
                          label: 'Remove',
                          onTap: onRemove,
                          iconColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
