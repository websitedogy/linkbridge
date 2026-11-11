import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/session.dart';
import '../theme.dart';

class CinVerifyScreen extends StatefulWidget {
  const CinVerifyScreen({super.key});

  @override
  State<CinVerifyScreen> createState() => _CinVerifyScreenState();
}

class _CinVerifyScreenState extends State<CinVerifyScreen> {
  final _cin = TextEditingController();
  String? _error;
  Map<String, String>? _result;

  static final _pattern = RegExp(
    r'^([LU])(\d{5})([A-Z]{2})(\d{4})([A-Z]{3})(\d{6})$',
  );
  static const _states = {
    'TG': 'Telangana',
    'TS': 'Telangana',
    'KA': 'Karnataka',
    'MH': 'Maharashtra',
    'DL': 'Delhi',
    'TN': 'Tamil Nadu',
    'GJ': 'Gujarat',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal',
    'AP': 'Andhra Pradesh',
  };
  static const _types = {
    'PTC': 'Private limited company',
    'PLC': 'Public limited company',
    'OPC': 'One person company',
    'NPL': 'Section 8 company',
  };

  @override
  void dispose() {
    _cin.dispose();
    super.dispose();
  }

  void _check() {
    final value = _cin.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final match = _pattern.firstMatch(value);
    if (match == null) {
      setState(() {
        _result = null;
        _error = 'Enter a 21-character CIN, such as U72900TG2020PTC123456.';
      });
      return;
    }
    final state = match.group(3)!;
    final type = match.group(5)!;
    setState(() {
      _cin.text = value;
      _error = null;
      _result = {
        'CIN': value,
        'Listing': match.group(1) == 'L'
            ? 'Listed company'
            : 'Unlisted company',
        'NIC code': match.group(2)!,
        'State': _states[state] == null ? state : '${_states[state]} ($state)',
        'Year': match.group(4)!,
        'Company type': _types[type] == null ? type : '${_types[type]} ($type)',
        'Registration number': match.group(6)!,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'CIN Verify',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check a Corporate Identification Number and read the parts encoded in it.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cin,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Corporate Identification Number',
              hintText: 'U72900TG2020PTC123456',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _check, child: const Text('Verify CIN')),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!),
            ),
          if (_result != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: deepGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in _result!.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(color: gold, fontSize: 12),
                          ),
                          Text(
                            entry.value,
                            style: const TextStyle(color: cream),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class LicencesScreen extends StatelessWidget {
  const LicencesScreen({super.key});

  static const _items = [
    ('LLP', 'Limited Liability Partnership', '4 companies'),
    ('Pvt Ltd', 'Private limited company', '14 companies'),
    ('OPC', 'One Person Company', '4 companies'),
    ('Section 8 Company', 'Not-for-profit company', '4 companies'),
    ('Nidhi Company', 'Mutual benefit company', '4 companies'),
    ('Producer Company', 'Producer company', '4 companies'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Licences',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Choose a company type to search the live marketplace.'),
          const SizedBox(height: 16),
          for (final item in _items)
            Card(
              child: ListTile(
                title: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(item.$2),
                trailing: Text(
                  item.$3,
                  style: const TextStyle(color: deepGreen),
                ),
                onTap: () => context.go(
                  '/buy?keyword=${Uri.encodeQueryComponent(item.$1)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AssistantButton extends ConsumerStatefulWidget {
  const AssistantButton({super.key});

  @override
  ConsumerState<AssistantButton> createState() => _AssistantButtonState();
}

class _AssistantButtonState extends ConsumerState<AssistantButton> {
  final _message = TextEditingController();
  bool _open = false;
  bool _busy = false;
  final _messages =
      <({bool user, String text, List<Map<String, String>> links})>[
        (
          user: false,
          text: 'Ask me about buying, selling, a CIN, or a city.',
          links: [],
        ),
      ];

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty || _busy) {
      return;
    }
    setState(() {
      _busy = true;
      _message.clear();
      _messages.add((user: true, text: text, links: []));
    });
    try {
      final reply = await ref.read(apiProvider).ask(text);
      final links = <Map<String, String>>[];
      final rawLinks = reply['links'];
      if (rawLinks is List) {
        for (final link in rawLinks) {
          if (link is Map) {
            links.add({
              'label': link['label']?.toString() ?? 'Open',
              'href': link['href']?.toString() ?? '/',
            });
          }
        }
      }
      setState(
        () => _messages.add((
          user: false,
          text: reply['reply']?.toString() ?? '',
          links: links,
        )),
      );
    } catch (error) {
      setState(
        () => _messages.add((user: false, text: error.toString(), links: [])),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openLink(String href) {
    final uri = Uri.parse(href);
    if (uri.path.startsWith('/businesses/')) {
      context.go('/listings/${uri.pathSegments.last}');
      return;
    }
    if (uri.path.startsWith('/seller')) {
      context.go('/register');
      return;
    }
    context.go(uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open)
          Container(
            width: MediaQuery.sizeOf(context).width - 32,
            height: (MediaQuery.sizeOf(context).height * 0.52).clamp(
              280.0,
              460.0,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(blurRadius: 24, color: Color(0x330F3D2F)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: deepGreen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LinksBridge',
                              style: TextStyle(
                                color: cream,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Marketplace assistant',
                              style: TextStyle(color: gold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _open = false),
                        icon: const Icon(Icons.close, color: cream),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final message in _messages)
                        Align(
                          alignment: message.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(maxWidth: 240),
                            decoration: BoxDecoration(
                              color: message.user ? deepGreen : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.user ? cream : charcoal,
                                  ),
                                ),
                                for (final link in message.links)
                                  TextButton(
                                    onPressed: () => _openLink(link['href']!),
                                    child: Text(link['label']!),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _message,
                          decoration: const InputDecoration(
                            hintText: 'Ask about a business',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : _send,
                        icon: const Icon(Icons.send, color: deepGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Theme(
          data: Theme.of(context).copyWith(
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              sizeConstraints: BoxConstraints.tightFor(width: 52, height: 52),
              iconSize: 22,
            ),
          ),
          child: FloatingActionButton(
            heroTag: 'linksbridge-chat',
            backgroundColor: deepGreen,
            foregroundColor: gold,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => setState(() => _open = !_open),
            child: Icon(_open ? Icons.close : Icons.chat_bubble_outline),
          ),
        ),
      ],
    );
  }
}
