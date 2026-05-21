import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/sign_search_result.dart';
import '../screens/sign_detail_screen.dart';

class SignResultListTile extends StatelessWidget {
  const SignResultListTile({
    super.key,
    required this.signApiClient,
    required this.sign,
  });

  final SignApiClient signApiClient;
  final SignSearchResult sign;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sign.englishWord),
      subtitle: Text('${sign.nepaliWord} · ${sign.category}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => SignDetailScreen(
              signApiClient: signApiClient,
              signId: sign.id,
            ),
          ),
        );
      },
    );
  }
}
