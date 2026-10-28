import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/progress.dart';

/// Accepts finalized metadata only, including a recovered result without a board.
class ShareButton extends StatefulWidget {
  const ShareButton({super.key, required this.result});
  final FinalizedResult result;
  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool busy = false;
  Future<void> copy() async {
    setState(() => busy = true);
    String message;
    try {
      await Clipboard.setData(ClipboardData(text: widget.result.shareText));
      message = 'Result copied';
    } catch (_) {
      message = 'Could not copy result. Please try again.';
    }
    if (!mounted) return;
    setState(() => busy = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('copy-result'),
    onPressed: busy ? null : copy,
    icon: const Icon(Icons.copy_rounded),
    label: const Text('Copy result'),
  );
}
