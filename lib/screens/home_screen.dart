import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmac_sha256/providers/generator_provider.dart';
import 'package:hmac_sha256/providers/validator_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int page) {
    setState(() => _selectedPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _Palette.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  selectedPage: _selectedPage,
                  onPageSelected: _selectPage,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (page) {
                      if (page != _selectedPage) {
                        setState(() => _selectedPage = page);
                      }
                    },
                    children: const [_GeneratorSection(), _ValidatorSection()],
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

class _Header extends StatelessWidget {
  const _Header({required this.selectedPage, required this.onPageSelected});

  final int selectedPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              const _BrandMark(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: selectedPage,
                  backgroundColor: _Palette.surface,
                  thumbColor: _Palette.accent,
                  padding: const EdgeInsets.all(4),
                  onValueChanged: (value) {
                    if (value != null) onPageSelected(value);
                  },
                  children: const {
                    0: _ModeLabel(
                      icon: CupertinoIcons.wand_rays,
                      label: 'Generator',
                    ),
                    1: _ModeLabel(
                      icon: CupertinoIcons.checkmark_shield,
                      label: 'Validator',
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _IconTile(icon: CupertinoIcons.lock_shield),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HMAC SHA256',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Generate and verify signatures locally',
                style: TextStyle(
                  color: _Palette.muted,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        _PrivacyBadge(),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: _Palette.accentGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5529D7C7),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: _Palette.background, size: 25),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _Palette.accent.withValues(alpha: 0.09),
        border: Border.all(color: _Palette.accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_shield,
            color: _Palette.accent,
            size: 14,
          ),
          SizedBox(width: 5),
          Text(
            'LOCAL',
            style: TextStyle(
              color: _Palette.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GeneratorSection extends ConsumerStatefulWidget {
  const _GeneratorSection();

  @override
  ConsumerState<_GeneratorSection> createState() => _GeneratorSectionState();
}

class _GeneratorSectionState extends ConsumerState<_GeneratorSection>
    with AutomaticKeepAliveClientMixin {
  String _message = '';
  String _key = '';
  bool _isCopying = false;
  bool _didCopy = false;
  Timer? _copyResetTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    super.dispose();
  }

  void _generate() {
    ref.read(generatorProvider.notifier).generate(_message, _key);
  }

  Future<void> _copyResult(String result) async {
    if (_isCopying || result.isEmpty) return;
    setState(() => _isCopying = true);
    await Clipboard.setData(ClipboardData(text: result));
    if (!mounted) return;

    _copyResetTimer?.cancel();
    setState(() {
      _isCopying = false;
      _didCopy = true;
    });
    _copyResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _didCopy = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final result = ref.watch(generatorProvider);

    return _PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            eyebrow: 'CREATE SIGNATURE',
            title: 'HMAC SHA256 Generator',
            description: 'Enter a message and secret key to create a deterministic, 256-bit authentication code.',
          ),
          const SizedBox(height: 22),
          _ContentCard(
            child: Column(
              children: [
                _AppTextField(
                  label: 'Message',
                  hint: 'The content you want to sign',
                  icon: CupertinoIcons.text_alignleft,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (value) {
                    _message = value;
                    _generate();
                  },
                ),
                const SizedBox(height: 18),
                _AppTextField(
                  label: 'Secret key',
                  hint: 'Your private signing key',
                  icon: CupertinoIcons.lock,
                  onChanged: (value) {
                    _key = value;
                    _generate();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ResultCard(
            result: result,
            isCopying: _isCopying,
            didCopy: _didCopy,
            onCopy: () => _copyResult(result),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.isCopying,
    required this.didCopy,
    required this.onCopy,
  });

  final String result;
  final bool isCopying;
  final bool didCopy;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.isEmpty
            ? _Palette.surface.withValues(alpha: 0.72)
            : _Palette.accent.withValues(alpha: 0.075),
        border: Border.all(
          color: result.isEmpty
              ? _Palette.border
              : _Palette.accent.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: result.isEmpty
            ? const _EmptyResult(key: ValueKey('empty'))
            : Column(
                key: const ValueKey('result'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'GENERATED SIGNATURE',
                          style: _Palette.eyebrowStyle,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        color: _Palette.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        onPressed: onCopy,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: isCopying
                              ? const CupertinoActivityIndicator(
                                  key: ValueKey('copying'),
                                  radius: 8,
                                  color: _Palette.accent,
                                )
                              : Row(
                                  key: ValueKey(didCopy),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      didCopy
                                          ? CupertinoIcons.checkmark
                                          : CupertinoIcons.doc_on_doc,
                                      size: 14,
                                      color: _Palette.accent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      didCopy ? 'Copied' : 'Copy',
                                      style: const TextStyle(
                                        color: _Palette.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SelectableText(
                    result,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 15,
                      fontFamily: 'monospace',
                      height: 1.6,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(CupertinoIcons.sparkles, color: _Palette.muted, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Your signature will appear here as soon as both fields are ready.',
            style: TextStyle(color: _Palette.muted, fontSize: 14, height: 1.4),
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

class _ValidatorSectionState extends ConsumerState<_ValidatorSection>
    with AutomaticKeepAliveClientMixin {
  String _message = '';
  String _key = '';
  String _hash = '';

  @override
  bool get wantKeepAlive => true;

  bool get _isReady =>
      _message.isNotEmpty && _key.isNotEmpty && _hash.isNotEmpty;

  void _validate() {
    ref.read(validatorProvider.notifier).validate(_message, _key, _hash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isValid = ref.watch(validatorProvider);

    return _PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            eyebrow: 'VERIFY SIGNATURE',
            title: 'HMAC SHA256 Validator',
            description: 'Recalculate the signature with the original message and key, then compare it safely.',
          ),
          const SizedBox(height: 22),
          _ContentCard(
            child: Column(
              children: [
                _AppTextField(
                  label: 'Message',
                  hint: 'The original signed content',
                  icon: CupertinoIcons.text_alignleft,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (value) {
                    _message = value;
                    _validate();
                  },
                ),
                const SizedBox(height: 18),
                _AppTextField(
                  label: 'Secret key',
                  hint: 'The original signing key',
                  icon: CupertinoIcons.lock,
                  onChanged: (value) {
                    _key = value;
                    _validate();
                  },
                ),
                const SizedBox(height: 18),
                _AppTextField(
                  label: 'Expected signature',
                  hint: 'Paste the 64-character hexadecimal hash',
                  icon: CupertinoIcons.number,
                  minLines: 2,
                  maxLines: 3,
                  onChanged: (value) {
                    _hash = value;
                    _validate();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ValidationCard(isReady: _isReady, isValid: isValid),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.isReady, required this.isValid});

  final bool isReady;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = !isReady
        ? _Palette.muted
        : isValid
        ? _Palette.accent
        : _Palette.danger;
    final title = !isReady
        ? 'Waiting for all fields'
        : isValid
        ? 'Signature is valid'
        : 'Signature does not match';
    final description = !isReady
        ? 'Complete the message, key, and expected signature to run validation.'
        : isValid
        ? 'The calculated HMAC matches the expected signature.'
        : 'Check the message, secret key, and signature for differences.';
    final icon = !isReady
        ? CupertinoIcons.ellipsis_circle
        : isValid
        ? CupertinoIcons.checkmark_circle_fill
        : CupertinoIcons.xmark_circle_fill;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(icon, key: ValueKey(icon), color: color, size: 31),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Column(
                key: ValueKey(title),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: _Palette.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: _Palette.eyebrowStyle),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          description,
          style: const TextStyle(
            color: _Palette.muted,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Palette.surfaceRaised, _Palette.surface],
        ),
        border: Border.all(color: _Palette.border),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _Palette.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        CupertinoTextField(
          minLines: minLines,
          maxLines: maxLines,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(icon, color: _Palette.muted, size: 19),
          ),
          placeholder: hint,
          placeholderStyle: const TextStyle(
            color: _Palette.placeholder,
            fontSize: 14,
          ),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            height: 1.4,
          ),
          cursorColor: _Palette.accent,
          clearButtonMode: OverlayVisibilityMode.editing,
          decoration: BoxDecoration(
            color: _Palette.input,
            border: Border.all(color: _Palette.border),
            borderRadius: BorderRadius.circular(14),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          right: -150,
          child: Container(
            width: 430,
            height: 430,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x2429D7C7), Color(0x0029D7C7)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -230,
          left: -190,
          child: Container(
            width: 520,
            height: 520,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x1C536DFE), Color(0x00536DFE)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

abstract final class _Palette {
  static const background = Color(0xFF080B12);
  static const surface = Color(0xFF111620);
  static const surfaceRaised = Color(0xFF171D29);
  static const input = Color(0xFF0D121B);
  static const border = Color(0xFF252D3C);
  static const accent = Color(0xFF42E2CE);
  static const danger = Color(0xFFFF667D);
  static const text = Color(0xFFE9EDF5);
  static const muted = Color(0xFF9099AA);
  static const placeholder = Color(0xFF596274);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF64F1DA), Color(0xFF27BFC1)],
  );

  static const eyebrowStyle = TextStyle(
    color: accent,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );
}
