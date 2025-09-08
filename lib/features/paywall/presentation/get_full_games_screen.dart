import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GetFullGamesScreen extends StatefulWidget {
  const GetFullGamesScreen({super.key});

  @override
  State<GetFullGamesScreen> createState() => _GetFullGamesScreenState();
}

class _GetFullGamesScreenState extends State<GetFullGamesScreen> {
  final _discountController = TextEditingController();
  bool _applying = false;
  bool _purchasing = false;
  String? _status;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    setState(() {
      _applying = true;
      _status = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _applying = false;
      _status = 'Discount code applied (demo)';
    });
  }

  Future<void> _purchase() async {
    setState(() {
      _purchasing = true;
      _status = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _purchasing = false;
      _status = 'Purchase flow would start here (Stripe)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Full Games'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Unlock all games with an annual subscription.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: 'Discount code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _applying ? null : _applyCode,
                child: _applying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply'),
              ),
            ),
            const Spacer(),
            if (_status != null) ...[
              Text(
                _status!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _purchasing ? null : _purchase,
                child: _purchasing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Purchase annual subscription'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

