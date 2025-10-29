import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          icon: Icons.facebook,
          onTap: () => _launchURL(AppConstants.facebookUrl),
        ),
        const SizedBox(width: 16),
        _SocialButton(
          icon: Icons.camera_alt, // Twitter/X icon
          onTap: () => _launchURL(AppConstants.twitterUrl),
        ),
        const SizedBox(width: 16),
        _SocialButton(
          icon: Icons.photo_camera, // Instagram icon
          onTap: () => _launchURL(AppConstants.instagramUrl),
        ),
        const SizedBox(width: 16),
        _SocialButton(
          icon: Icons.music_note, // TikTok icon
          onTap: () => _launchURL(AppConstants.tiktokUrl),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}
