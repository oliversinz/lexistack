import 'package:flutter/material.dart';

import '../app/progress_controller.dart';

class ProgressStatus extends StatelessWidget {
  const ProgressStatus({super.key, required this.controller});
  final ProgressController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!controller.initialized) ...[
        if (controller.loadWarning != null) ...[
          Text(controller.loadWarning!, key: const Key('load-warning')),
          TextButton(
            onPressed: controller.retryLoad,
            child: const Text('Retry load'),
          ),
        ] else
          const Text('Loading saved progress…'),
      ] else ...[
        Text(
          '${controller.state.coins} coins',
          key: const Key('wallet'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (controller.storageWarning != null) ...[
          Text(controller.storageWarning!, key: const Key('storage-warning')),
          TextButton(
            onPressed: controller.retrySave,
            child: const Text('Retry save'),
          ),
        ] else if (!controller.saved)
          const Text('Saving progress…'),
        if (controller.recoveryNotice != null)
          Text(controller.recoveryNotice!, key: const Key('recovery-notice')),
      ],
    ],
  );
}
