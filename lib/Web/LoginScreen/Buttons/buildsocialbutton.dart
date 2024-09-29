import 'package:dev_icons/dev_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_logic/Login_Auth/login_auth.dart';

class BuildSocialButton extends StatelessWidget {
  final Function? onTap;
  final IconData icon;
  final Color color;
  final String label;

  const BuildSocialButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 30),
            onPressed: onTap as void Function()?,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkFontColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

List<BuildSocialButton> returnListOfButtons(
    BuildContext context, Function tapbutton) {
  return [
    BuildSocialButton(
      onTap: tapbutton,
      icon: Icons.qr_code_2,
      color: Colors.green,
      label: 'QR_Scan',
    ),
    BuildSocialButton(
      onTap: () async {
        UserCredential? user = await signInWithGoogle(context);
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              returnSuccessSnackbar("Google Sign-in Successful......"));
        }
      },
      icon: DevIcons.googlePlain,
      color: Colors.red,
      label: 'Google',
    ),
    BuildSocialButton(
      onTap: () async {
        UserCredential? user = await gitHubSignIn(context);
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              returnSuccessSnackbar("Google Sign-in Successful......"));
        }
      },
      icon: DevIcons.githubOriginal,
      color: Colors.black,
      label: 'Github',
    ),
  ];
}
