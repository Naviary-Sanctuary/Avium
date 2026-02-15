import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('앱 정보')),
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
                title: const Text('콘텐츠 버전'),
                subtitle: Text(meta.dataVersion),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('마지막 검토일'),
                subtitle: Text(meta.reviewedAt),
              ),
              const SizedBox(height: 8),
              Text(
                '안내',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                '• 이 앱은 앵무새 급여/안전 판단을 돕는 참고용 정보 앱입니다.',
              ),
              const Text('• 증상이 있거나 불안하면 바로 진료기관에 문의하세요.'),
            ],
          );
        },
      ),
    );
  }
}
