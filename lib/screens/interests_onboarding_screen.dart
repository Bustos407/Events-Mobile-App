import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/interests.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

/// Used both for the initial registration flow (name/email/password provided)
/// and for editing interests of an already logged-in user (those left null).
class InterestsOnboardingScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;

  const InterestsOnboardingScreen({super.key, this.name, this.email, this.password});

  bool get isRegisterFlow => name != null;

  @override
  State<InterestsOnboardingScreen> createState() => _InterestsOnboardingScreenState();
}

class _InterestsOnboardingScreenState extends State<InterestsOnboardingScreen> {
  final Set<String> _selected = {};
  bool _submitting = false;
  String? _error;

  Future<void> _finish() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Selecciona al menos un interés.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    if (widget.isRegisterFlow) {
      final error = await auth.register(
        name: widget.name!,
        email: widget.email!,
        password: widget.password!,
        interests: _selected.toList(),
      );
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _submitting = false;
          _error = error;
        });
        return;
      }
    } else {
      await auth.updateInterests(_selected.toList());
    }
    if (!mounted) return;
    if (widget.isRegisterFlow) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Qué te interesa?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Elige tus intereses para que te mostremos eventos relevantes cerca de ti.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kAvailableInterests.map((interest) {
                    final isSelected = _selected.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selected.add(interest);
                          } else {
                            _selected.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _submitting ? null : _finish,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
