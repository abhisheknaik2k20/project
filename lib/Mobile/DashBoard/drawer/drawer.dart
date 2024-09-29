import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Mobile/DashBoard/QR_Scanner/qr_scanner.dart';

class EnhancedProfessionalSideDrawer extends StatelessWidget {
  const EnhancedProfessionalSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: Container(
        width: size.width * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, Icons.calendar_today, 'Schedule',
                      badge: '3'),
                  _buildDrawerItem(context, Icons.star_outline, 'Rewards',
                      badge: '2'),
                  _buildDrawerItem(
                      context, Icons.credit_card_outlined, 'Payment Methods'),
                  _buildDrawerItem(
                    context,
                    Icons.qr_code,
                    'QR_Scanner',
                    badge: '3',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QRScannerScreen(),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                      context, Icons.person_add_outlined, 'Refer a Friend'),
                  _buildDrawerItem(
                      context, Icons.support_agent_outlined, 'Support'),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], thickness: 0.5),
            _buildThemeToggle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double paddingFactor = size.width * 0.05;
    final double fontSizeFactor = size.width * 0.004;

    return Container(
      padding: EdgeInsets.fromLTRB(
          paddingFactor, size.height * 0.07, paddingFactor, paddingFactor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: size.width * 0.08,
            child: Icon(
              Icons.account_circle,
              size: size.width * 0.14,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            FirebaseAuth.instance.currentUser!.displayName ?? "None",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * fontSizeFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            FirebaseAuth.instance.currentUser!.email ?? "None",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14 * fontSizeFactor,
            ),
          ),
          SizedBox(height: size.height * 0.025),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      {String? badge, void Function()? onTap}) {
    final Size size = MediaQuery.of(context).size;
    final double paddingFactor = size.width * 0.04;
    final double fontSizeFactor = size.width * 0.003;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: paddingFactor, vertical: size.height * 0.01),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 22 * fontSizeFactor),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16 * fontSizeFactor),
        ),
        trailing: badge != null
            ? Container(
                padding: EdgeInsets.symmetric(
                    horizontal: paddingFactor, vertical: size.height * 0.003),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                      color: Colors.white, fontSize: 12 * fontSizeFactor),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double paddingFactor = size.width * 0.04;
    final double fontSizeFactor = size.width * 0.003;

    return Container(
      margin: EdgeInsets.all(paddingFactor),
      padding: EdgeInsets.symmetric(
          horizontal: paddingFactor, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Colour Scheme',
              style: TextStyle(
                  color: Colors.white, fontSize: 16 * fontSizeFactor)),
          Row(
            children: [
              Text('Light',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 14 * fontSizeFactor)),
              SizedBox(width: size.width * 0.02),
              Switch(
                value: true,
                onChanged: (value) {
                  // Handle theme change
                },
                activeColor: Colors.blue,
                activeTrackColor: Colors.blue.withOpacity(0.5),
              ),
              SizedBox(width: size.width * 0.02),
              Text('Dark',
                  style: TextStyle(
                      color: Colors.white, fontSize: 14 * fontSizeFactor)),
            ],
          ),
        ],
      ),
    );
  }
}
