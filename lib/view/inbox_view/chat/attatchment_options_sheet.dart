import 'package:flutter/material.dart';

class AttachmentOptionsSheet extends StatelessWidget {
  const AttachmentOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _Option(icon: Icons.camera_alt, label: 'Take Photo', onTap: () => Navigator.pop(context, 'camera_image')),
      _Option(icon: Icons.videocam, label: 'Record Video', onTap: () => Navigator.pop(context, 'camera_video')),
      _Option(icon: Icons.photo_library, label: 'Gallery', onTap: () => Navigator.pop(context, 'gallery')),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Center(
              child: Text('Attach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: options.map((opt) => _OptionTile(option: opt)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Option({required this.icon, required this.label, required this.onTap});
}

class _OptionTile extends StatelessWidget {
  final _Option option;
  const _OptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.grey[200], child: Icon(option.icon, size: 28)),
          const SizedBox(height: 8),
          Text(option.label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
