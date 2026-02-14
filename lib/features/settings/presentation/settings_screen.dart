import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final meta = appState.meta;
          if (appState.isInitializing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (meta == null) {
            return const Center(child: Text('데이터 메타 정보를 불러올 수 없습니다.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('dataVersion'),
                subtitle: Text(meta.dataVersion),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('reviewedAt'),
                subtitle: Text(meta.reviewedAt),
              ),
              const SizedBox(height: 8),
              Text(
                '배포 정책',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...meta.distributionPolicyKo.map((line) => Text('• $line')),
            ],
          );
        },
      ),
    );
  }
}
