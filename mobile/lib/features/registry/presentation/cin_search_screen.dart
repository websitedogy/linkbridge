import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../home/presentation/sell_company_screen.dart';
import '../application/registry_search.dart';
import '../data/registry_mock.dart';

enum _LookupKind { cin, din }

class CinSearchScreen extends ConsumerStatefulWidget {
  const CinSearchScreen({super.key});

  @override
  ConsumerState<CinSearchScreen> createState() => _CinSearchScreenState();
}

class _CinSearchScreenState extends ConsumerState<CinSearchScreen> {
  final _input = TextEditingController();
  var _kind = _LookupKind.cin;
  var _loading = false;
  String? _fieldError;
  String? _lookupError;
  CinRecord? _company;
  DinRecord? _director;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _search([String? preset]) async {
    final raw = (preset ?? _input.text).trim();
    if (preset != null) _input.text = preset;
    final value = _kind == _LookupKind.cin ? raw.toUpperCase() : raw;
    if (_kind == _LookupKind.cin && !RegistryMock.cinPattern.hasMatch(value)) {
      setState(() {
        _fieldError = 'Enter a valid 21-character CIN';
        _lookupError = null;
        _company = null;
        _director = null;
        _loading = false;
      });
      return;
    }
    if (_kind == _LookupKind.din && !RegistryMock.dinPattern.hasMatch(value)) {
      setState(() {
        _fieldError = 'Enter a valid 8-digit DIN';
        _lookupError = null;
        _company = null;
        _director = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _fieldError = null;
      _lookupError = null;
      _company = null;
      _director = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (_kind == _LookupKind.cin) {
      final record = RegistryMock.findCin(value);
      ref
          .read(registrySearchHistoryProvider.notifier)
          .add(
            RegistrySearchEntry(
              query: value,
              kind: 'CIN',
              found: record != null,
            ),
          );
      setState(() {
        _loading = false;
        _company = record;
        _lookupError = record == null ? 'Not found / invalid CIN' : null;
      });
      return;
    }

    final record = RegistryMock.findDin(value);
    ref
        .read(registrySearchHistoryProvider.notifier)
        .add(
          RegistrySearchEntry(query: value, kind: 'DIN', found: record != null),
        );
    setState(() {
      _loading = false;
      _director = record;
      _lookupError = record == null ? 'Not found / invalid DIN' : null;
    });
  }

  void _share(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Details copied to share')));
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(registrySearchHistoryProvider);
    final saved = ref.watch(savedRegistryProvider);
    final showEmpty =
        !_loading &&
        _company == null &&
        _director == null &&
        _lookupError == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('CIN / DIN Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(
              children: [
                _Toggle(
                  label: 'Company (CIN)',
                  selected: _kind == _LookupKind.cin,
                  onTap: () => setState(() {
                    _kind = _LookupKind.cin;
                    _fieldError = null;
                    _lookupError = null;
                    _company = null;
                    _director = null;
                  }),
                ),
                _Toggle(
                  label: 'Director (DIN)',
                  selected: _kind == _LookupKind.din,
                  onTap: () => setState(() {
                    _kind = _LookupKind.din;
                    _fieldError = null;
                    _lookupError = null;
                    _company = null;
                    _director = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _input,
            textCapitalization: _kind == _LookupKind.cin
                ? TextCapitalization.characters
                : TextCapitalization.none,
            keyboardType: _kind == _LookupKind.din
                ? TextInputType.number
                : TextInputType.text,
            maxLength: _kind == _LookupKind.cin ? 21 : 8,
            style: AppTypography.body(),
            decoration: InputDecoration(
              counterText: '',
              hintText: _kind == _LookupKind.cin
                  ? '21-character CIN'
                  : '8-digit DIN',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              errorText: _fieldError,
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Search',
            onPressed: _loading ? null : () => _search(),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading) const _LookupShimmer(),
          if (_lookupError != null) _ErrorCard(message: _lookupError!),
          if (_company != null)
            _CompanyCard(
              record: _company!,
              saved: saved.contains(_company!.cin),
              onSave: () => ref
                  .read(savedRegistryProvider.notifier)
                  .toggle(_company!.cin),
              onShare: () => _share(
                '${_company!.name}\nCIN ${_company!.cin}\n${_company!.status}\n${_company!.address}',
              ),
              onList: () => context.pushNamed(
                AppRoutes.sell,
                extra: ListingPrefill(
                  cin: _company!.cin,
                  name: _company!.name,
                  location: _company!.address,
                  companyTypeId: _company!.companyTypeId,
                  description:
                      '${_company!.name} (${_company!.cin}) is ${_company!.status}.',
                ),
              ),
            ),
          if (_director != null)
            _DirectorCard(
              record: _director!,
              saved: saved.contains(_director!.din),
              onSave: () => ref
                  .read(savedRegistryProvider.notifier)
                  .toggle(_director!.din),
              onShare: () => _share(
                '${_director!.name}\nDIN ${_director!.din}\n${_director!.status}',
              ),
            ),
          if (showEmpty) ...[
            const _EmptyLookup(),
            const SizedBox(height: AppSpacing.md),
            Text('Try a sample', style: AppTypography.section()),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sample in const [
                  'U72900TG2018PTC123456',
                  '01234567',
                ])
                  ActionChip(
                    label: Text(sample, style: AppTypography.caption()),
                    onPressed: () {
                      setState(
                        () => _kind = sample.length == 8
                            ? _LookupKind.din
                            : _LookupKind.cin,
                      );
                      _search(sample);
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Recent searches', style: AppTypography.section()),
            const SizedBox(height: AppSpacing.xs),
            if (history.isEmpty)
              Text('No searches yet', style: AppTypography.bodySmall())
            else
              for (final entry in history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    entry.found ? Icons.history : Icons.error_outline,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(
                    entry.query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(entry.found ? entry.kind : 'Not found'),
                  onTap: () {
                    setState(
                      () => _kind = entry.kind == 'DIN'
                          ? _LookupKind.din
                          : _LookupKind.cin,
                    );
                    _search(entry.query);
                  },
                ),
          ],
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyLookup extends StatelessWidget {
  const _EmptyLookup();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          const Icon(Icons.manage_search, size: 40, color: AppColors.gold),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Look up a company or director',
            style: AppTypography.section(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'CIN is 21 characters. DIN is 8 digits.',
            style: AppTypography.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: const Color(0xFFF3C7C4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.record,
    required this.saved,
    required this.onSave,
    required this.onShare,
    required this.onList,
  });

  final CinRecord record;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onList;

  @override
  Widget build(BuildContext context) {
    final active = record.status == 'Active';
    return _ResultFrame(
      children: [
        Text(record.name, style: AppTypography.section()),
        const SizedBox(height: AppSpacing.xxs),
        Text(record.cin, style: AppTypography.caption()),
        const SizedBox(height: AppSpacing.sm),
        _StatusPill(label: record.status, active: active),
        const SizedBox(height: AppSpacing.sm),
        _Line(label: 'Incorporation', value: record.incorporationDate),
        _Line(label: 'Company type', value: record.companyType),
        _Line(label: 'Registered address', value: record.address),
        _Line(label: 'Authorized capital', value: record.authorizedCapital),
        _Line(label: 'Paid-up capital', value: record.paidUpCapital),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Directors',
          style: AppTypography.body(
            color: AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        for (final director in record.directors)
          Text(
            director,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(),
          ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'List this company for sale', onPressed: onList),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSave,
                child: Text(saved ? 'Saved' : 'Save'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: onShare,
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirectorCard extends StatelessWidget {
  const _DirectorCard({
    required this.record,
    required this.saved,
    required this.onSave,
    required this.onShare,
  });

  final DinRecord record;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return _ResultFrame(
      children: [
        Text(record.name, style: AppTypography.section()),
        const SizedBox(height: AppSpacing.xxs),
        Text('DIN ${record.din}', style: AppTypography.caption()),
        const SizedBox(height: AppSpacing.sm),
        _StatusPill(label: record.status, active: record.status == 'Approved'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Associated companies',
          style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
        ),
        for (final company in record.companies)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(),
                ),
                Text(
                  company.cin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSave,
                child: Text(saved ? 'Saved' : 'Save'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: onShare,
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultFrame extends StatelessWidget {
  const _ResultFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption()),
          Text(value, style: AppTypography.body()),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.featured : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption(
          color: color,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _LookupShimmer extends StatefulWidget {
  const _LookupShimmer();

  @override
  State<_LookupShimmer> createState() => _LookupShimmerState();
}

class _LookupShimmerState extends State<_LookupShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.9).animate(_controller),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              height: i == 0 ? 22 : 14,
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}
