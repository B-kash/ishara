import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/friendly_error_message.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/app_snackbar.dart';
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

      if (!mounted) {
        return;
      }

      setState(() {
        _detailState = AsyncViewState.success(signDetail);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final friendlyMessage = friendlyApiErrorMessage(
        context,
        error,
        FetchErrorContext.signDetail,
      );

      if (error is SignApiException &&
          error.kind == SignApiErrorKind.signNotFound) {
        setState(() {
          _detailState = AsyncViewState.empty();
        });
      } else {
        setState(() {
          _detailState = AsyncViewState.error();
        });
      }

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyMessage,
        onRetry: _loadSignDetail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appBarTitle = _detailState.data?.englishWord ?? l10n.signDetailTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: AsyncStateBody<SignDetail>(
        state: _detailState,
        onRetry: _loadSignDetail,
        errorTitle: l10n.couldNotLoadSign,
        emptyMessage: l10n.signNotFound,
        successBuilder: (context, signDetail) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SignMediaPanel(signDetail: signDetail),
              const SizedBox(height: 24),
              _DetailRow(
                label: l10n.detailEnglish,
                value: signDetail.englishWord,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.detailNepali,
                value: signDetail.nepaliWord,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.detailCategory,
                value: signDetail.category,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.detailMeaning,
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
