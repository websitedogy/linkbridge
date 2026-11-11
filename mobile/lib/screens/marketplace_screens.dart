import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_exception.dart';
import '../state/session.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text);
      if (mounted) context.go('/');
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: const Text('Log in'),
          ),
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.initialRole = 'buyer'});

  final String initialRole;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late String _role;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole == 'seller' ? 'seller' : 'buyer';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .signUp(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            role: _role,
          );
      if (mounted) context.go('/');
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'buyer', label: Text('Buyer')),
              ButtonSegment(value: 'seller', label: Text('Seller')),
            ],
            selected: {_role},
            onSelectionChanged: (value) => setState(() => _role = value.first),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({
    super.key,
    this.title = 'Listings',
    this.initialKeyword = '',
    this.initialCity = '',
  });

  final String title;
  final String initialKeyword;
  final String initialCity;

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  final _keyword = TextEditingController();
  late Future<List<Map<String, dynamic>>> _listings;

  @override
  void initState() {
    super.initState();
    _keyword.text = widget.initialKeyword;
    _listings = _load();
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final params = <String, String>{};
    final keyword = _keyword.text.trim();
    if (keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }
    if (widget.initialCity.isNotEmpty) {
      params['city'] = widget.initialCity;
    }
    final query = params.isEmpty
        ? ''
        : '?${Uri(queryParameters: params).query}';
    return ref.read(apiProvider).listings(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keyword,
                    decoration: const InputDecoration(labelText: 'Search'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() => _listings = _load()),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _listings,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(_message(snapshot.error!)));
                }
                final rows = snapshot.data ?? const [];
                if (rows.isEmpty) {
                  return const Center(
                    child: Text('No published listings match this search.'),
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final listing = rows[index];
                    final company = listing['company'] as Map<String, dynamic>?;
                    return ListTile(
                      title: Text(listing['title']?.toString() ?? 'Listing'),
                      subtitle: Text(company?['public_name']?.toString() ?? ''),
                      onTap: () => context.go('/listings/${listing['slug']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  late Future<Map<String, dynamic>> _listing;
  final _messageController = TextEditingController(
    text: 'I would like to learn more about this business.',
  );
  String? _notice;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listing = ref.read(apiProvider).listing(widget.slug);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(String id) action) async {
    final listing = await _listing;
    try {
      await action(listing['id'].toString());
      setState(() {
        _notice = 'Request sent.';
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _messageFor(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _listing,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(_message(snapshot.error ?? 'Missing listing')),
            );
          }
          final listing = snapshot.data!;
          final company = listing['company'] as Map<String, dynamic>?;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                listing['title']?.toString() ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(company?['public_name']?.toString() ?? ''),
              const SizedBox(height: 12),
              Text(listing['short_description']?.toString() ?? ''),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              ),
              if (_notice != null) Text(_notice!),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              if (session.value?['role'] == 'BUYER') ...[
                FilledButton(
                  onPressed: () =>
                      _run((id) => ref.read(apiProvider).favorite(id)),
                  child: const Text('Save'),
                ),
                FilledButton(
                  onPressed: () => _run(
                    (id) => ref
                        .read(apiProvider)
                        .expressInterest(id, _messageController.text),
                  ),
                  child: const Text('Express interest'),
                ),
              ] else
                const Text(
                  'Sign in as a buyer to save this listing or express interest.',
                ),
            ],
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(apiProvider).favorites(),
        builder: (context, snapshot) =>
            _resultList(snapshot, empty: 'No saved listings.'),
      ),
    );
  }
}

class InterestsScreen extends ConsumerWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interests')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(apiProvider).interests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(_message(snapshot.error!)));
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return const Center(
              child: Text('You have not expressed interest yet.'),
            );
          }
          return ListView(
            children: [
              for (final interest in rows)
                ListTile(
                  title: Text(
                    (interest['listing'] as Map?)?['title']?.toString() ??
                        'Listing',
                  ),
                  subtitle: Text(interest['status']?.toString() ?? ''),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: session.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Log in'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                user['name']?.toString() ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(user['email']?.toString() ?? ''),
              Text('Role: ${user['role']}'),
              Text('Status: ${user['status']}'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(sessionProvider.notifier).signOut();
                  if (context.mounted) context.go('/');
                },
                child: const Text('Log out'),
              ),
            ],
          );
        },
        error: (error, stack) => Center(child: Text(_message(error))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

Widget _resultList(
  AsyncSnapshot<List<Map<String, dynamic>>> snapshot, {
  required String empty,
}) {
  if (snapshot.connectionState != ConnectionState.done) {
    return const Center(child: CircularProgressIndicator());
  }
  if (snapshot.hasError) {
    return Center(child: Text(_message(snapshot.error!)));
  }
  final rows = snapshot.data ?? const [];
  if (rows.isEmpty) {
    return Center(child: Text(empty));
  }
  return ListView(
    children: [
      for (final listing in rows)
        ListTile(
          title: Text(listing['title']?.toString() ?? 'Listing'),
          subtitle: Text(
            (listing['company'] as Map?)?['public_name']?.toString() ?? '',
          ),
        ),
    ],
  );
}

String _message(Object error) =>
    error is ApiException ? error.message : error.toString();

String _messageFor(Object error) => _message(error);
