// guardians_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Mobile/chat_room.dart';
import 'package:project/firebase_logic/webRTC/webrtcengine.dart';

class GuardianListPage extends StatefulWidget {
  const GuardianListPage({Key? key}) : super(key: key);

  @override
  _GuardianListPageState createState() => _GuardianListPageState();
}

class _GuardianListPageState extends State<GuardianListPage> {
  // Track which guardian items are expanded
  final Set<String> _expandedGuardians = Set<String>();

  // Get current user's uid
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fetch guardians from the current user's subcollection
  Stream<QuerySnapshot> _getGuardians() {
    if (currentUser == null) {
      // Handle null user, perhaps return an empty stream or throw an error
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('guardians')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Guardians')),
        ),
        body: const Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardians'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getGuardians(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching guardians'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there are guardians
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No guardians found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              var data = document.data()! as Map<String, dynamic>;
              String guardianId = document.id;
              String name = data['name'] ?? 'No Name';
              String phone = data['phone'] ?? 'No Phone';
              String email = data['email'] ?? 'No Email';

              return GuardianListItem(
                guardianId: guardianId,
                name: name,
                phone: phone,
                email: email,
                isExpanded: _expandedGuardians.contains(guardianId),
                onExpandToggle: () {
                  setState(() {
                    if (_expandedGuardians.contains(guardianId)) {
                      _expandedGuardians.remove(guardianId);
                    } else {
                      _expandedGuardians.add(guardianId);
                    }
                  });
                },
                onVideoCall: () {
                  // Implement video call functionality
                  print('Video call with $name');
                },
                onText: () {
                  // Implement text functionality
                  print('Text with $name');
                },
                onRemove: () {
                  _showRemoveConfirmation(context, guardianId, name);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGuardianDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows a confirmation dialog before removing a guardian
  void _showRemoveConfirmation(
      BuildContext context, String guardianId, String guardianName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Guardian'),
          content: Text(
              'Are you sure you want to remove $guardianName as a guardian?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('guardians')
                    .doc(guardianId)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$guardianName removed')),
                  );
                }).catchError((error) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to remove guardian: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to add a guardian by entering their GID
  void _showAddGuardianDialog(BuildContext context) {
    final TextEditingController _gidController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Guardian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _gidController,
                decoration:
                    const InputDecoration(labelText: 'Enter Guardian ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () async {
                String gid = _gidController.text.trim();
                if (gid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an ID')),
                  );
                  return;
                }

                // Fetch guardian data based on gid from the main 'guardians' collection
                var guardianSnapshot = await FirebaseFirestore.instance
                    .collection('guardians')
                    .doc(gid)
                    .get();
                if (guardianSnapshot.exists) {
                  var guardianData = guardianSnapshot.data()!;
                  String name = guardianData['name'] ?? 'No Name';
                  String phone = guardianData['phone'] ?? 'No Phone';
                  String email = guardianData['email'] ?? 'No Email';

                  // Check if the guardian is already added
                  var existingGuardian = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('guardians')
                      .doc(gid)
                      .get();

                  if (existingGuardian.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardian already added')),
                    );
                    Navigator.of(context).pop(); // Close the search dialog
                    return;
                  }

                  // Show confirmation dialog with guardian details
                  Navigator.of(context).pop(); // Close the search dialog

                  _showConfirmAddGuardianDialog(
                      context, gid, name, phone, email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guardian not found')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog to add the guardian to the user's subcollection
  void _showConfirmAddGuardianDialog(BuildContext context, String gid,
      String name, String phone, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Add Guardian'),
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
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                // Add guardian to the user's subcollection 'guardians'
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('guardians')
                    .doc(gid)
                    .set({
                  'name': name,
                  'phone': phone,
                  'email': email,
                  'gid': gid,
                }).then((_) async {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name added as guardian')),
                  );
                  await FirebaseFirestore.instance
                      .collection('guardians')
                      .doc(gid)
                      .collection('users')
                      .doc(currentUser!.uid)
                      .set({
                    'name': currentUser!.displayName,
                    'email': currentUser!.email,
                  });
                }).catchError((error) {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add guardian: $error')),
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

class GuardianListItem extends StatelessWidget {
  final String guardianId;
  final String name;
  final String phone;
  final String email;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onVideoCall;
  final VoidCallback onText;
  final VoidCallback onRemove;

  const GuardianListItem({
    Key? key,
    required this.guardianId,
    required this.name,
    required this.phone,
    required this.email,
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
            // Header Row: Name and "..." Icon
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
            // Expanded Details: Email, Phone, and Action Icons
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
                    // Phone
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
                    const SizedBox(height: 10),
                    // Action Icons: Video Call, Voice Call, Text, Remove
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOptionIcon(
                          icon: Icons.video_call,
                          label: 'Video Call',
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AgoraRoom()));
                          },
                        ),
                        _buildOptionIcon(
                          icon: Icons.message,
                          label: 'Chat',
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatRoomScreen(userdata: {"name":name,"uid":guardianId})));
                          },
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

  /// Builds an option icon with a label
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
