import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmac_sha256/providers/generator_provider.dart';
import 'package:hmac_sha256/providers/validator_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _titles = {
    0: 'HMAC SHA256 Generator',
    1: 'HMAC SHA256 Validator',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wand_rays),
            label: 'Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.checkmark_shield),
            label: 'Validator',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(_titles[index]!),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: index == 0 ? _GeneratorSection() : _ValidatorSection(),
            ),
          ),
        );
      },
    );
  }
}

class _GeneratorSection extends ConsumerStatefulWidget {
  const _GeneratorSection();

  @override
  ConsumerState<_GeneratorSection> createState() => _GeneratorSectionState();
}

class _GeneratorSectionState extends ConsumerState<_GeneratorSection> {
  String message = '';
  String key = '';

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(generatorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Generator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Message',
          padding: const EdgeInsets.all(12),
          onChanged: (value) {
            message = value;
            ref.read(generatorProvider.notifier).generate(message, key);
          },
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Key',
          padding: const EdgeInsets.all(12),
          onChanged: (value) {
            key = value;
            ref.read(generatorProvider.notifier).generate(message, key);
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'HMAC-SHA256 Result:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 177, 177, 206)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            result,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _ValidatorSection extends ConsumerStatefulWidget {
  const _ValidatorSection();

  @override
  ConsumerState<_ValidatorSection> createState() => _ValidatorSectionState();
}

class _ValidatorSectionState extends ConsumerState<_ValidatorSection> {
  String message = '';
  String key = '';
  String hash = '';

  @override
  Widget build(BuildContext context) {
    final isValid = ref.watch(validatorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Validator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Message',
          padding: const EdgeInsets.all(12),
          onChanged: (value) {
            message = value;
            ref.read(validatorProvider.notifier).validate(message, key, hash);
          },
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Key',
          padding: const EdgeInsets.all(12),
          onChanged: (value) {
            key = value;
            ref.read(validatorProvider.notifier).validate(message, key, hash);
          },
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Hash to Validate',
          padding: const EdgeInsets.all(12),
          onChanged: (value) {
            hash = value;
            ref.read(validatorProvider.notifier).validate(message, key, hash);
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Valid: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              isValid
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.xmark_circle_fill,
              color: isValid
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ],
        ),
      ],
    );
  }
}
