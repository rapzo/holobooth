import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.all(150),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF9E81EF),
            Color(0xFF4100E0),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020320).withOpacity(0.95),
          borderRadius: BorderRadius.circular(38),
        ),
      ),
    );
  }
}
