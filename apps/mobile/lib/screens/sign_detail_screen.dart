import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/sign_detail.dart';
import '../state/async_view_state.dart';
import '../widgets/async_state_body.dart';
import '../widgets/sign_media_panel.dart';

class SignDetailScreen extends StatefulWidget {
  const SignDetailScreen({
    super.key,
    required this.signApiClient,
    required this.signId,
  });

  final SignApiClient signApiClient;
  final String signId;

  @override
  State<SignDetailScreen> createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  AsyncViewState<SignDetail> _detailState = AsyncViewState.loading();

  @override
  void initState() {
    super.initState();
    _loadSignDetail();
  }

  Future<void> _loadSignDetail() async {
    setState(() {
      _detailState = AsyncViewState.loading();
    });

    try {
      final signDetail = await widget.signApiClient.getSignById(widget.signId);
      setState(() {
        _detailState = AsyncViewState.success(signDetail);
      });
    } catch (error) {
      setState(() {
        _detailState = AsyncViewState.error(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _detailState.data?.englishWord ?? 'Sign detail';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: AsyncStateBody<SignDetail>(
        state: _detailState,
        onRetry: _loadSignDetail,
        errorTitle: 'Could not load sign',
        emptyMessage: 'Sign not found.',
        successBuilder: (context, signDetail) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SignMediaPanel(signDetail: signDetail),
              const SizedBox(height: 24),
              _DetailRow(label: 'English', value: signDetail.englishWord),
              const SizedBox(height: 12),
              _DetailRow(label: 'Nepali', value: signDetail.nepaliWord),
              const SizedBox(height: 12),
              _DetailRow(label: 'Category', value: signDetail.category),
              const SizedBox(height: 20),
              Text(
                'Meaning',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(signDetail.meaning),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
