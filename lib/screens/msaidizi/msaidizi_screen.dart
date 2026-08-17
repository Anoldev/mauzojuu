import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/mazungumzo.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';

// Maswali ya haraka (suggested chips)
const _maswaliYaHaraka = [
  '📊 Mauzo ya leo ni ngapi?',
  '📦 Bidhaa zipi zinakwisha?',
  '💡 Nipe ushauri wa mauzo',
  '🛒 Maagizo yanayosubiri?',
  '💰 Niambie bei bora',
  '📢 Jinsi ya kutangaza bidhaa',
];

class MsaidiaziScreen extends ConsumerStatefulWidget {
  const MsaidiaziScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MsaidiaziScreen> createState() => _MsaidiaziScreenState();
}

class _MsaidiaziScreenState extends ConsumerState<MsaidiaziScreen>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _inasubiri = false;
  bool _karibishoLimesha = false; // ignore: unused_field

  late AnimationController _typingCtrl;

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _anza();
  }

  Future<void> _anza() async {
    // Karibisho — pata kutoka AI (na data halisi)
    final historia = ref.read(mazungumzoProvider);
    if (historia.isEmpty) {
      setState(() => _inasubiri = true);
      final jibu = await ref.read(aiServiceProvider).ujumbeWaKaribisho();
      if (mounted) {
        setState(() {
          _inasubiri = false;
          _karibishoLimesha = true;
        });
        ref.read(mazungumzoProvider.notifier).ongezaUjumbe(UjumbeModel(
              id: const Uuid().v4(),
              maudhui: jibu,
              niAI: true,
              wakati: DateTime.now(),
            ));
        _scrollChini();
      }
    } else {
      setState(() => _karibishoLimesha = true);
    }
  }

  Future<void> _tumaMujumbe(String maandishi) async {
    if (maandishi.trim().isEmpty || _inasubiri) return;

    _inputCtrl.clear();
    _focusNode.unfocus();

    final ujumbeWaMtumiaji = UjumbeModel(
      id: const Uuid().v4(),
      maudhui: maandishi.trim(),
      niAI: false,
      wakati: DateTime.now(),
    );

    ref.read(mazungumzoProvider.notifier).ongezaUjumbe(ujumbeWaMtumiaji);
    _scrollChini();
    setState(() => _inasubiri = true);

    final historia = ref.read(mazungumzoProvider);
    final jibu = await ref.read(aiServiceProvider).ulizaAI(
          swali: maandishi.trim(),
          historia: historia,
        );

    if (mounted) {
      setState(() => _inasubiri = false);
      ref.read(mazungumzoProvider.notifier).ongezaUjumbe(UjumbeModel(
            id: const Uuid().v4(),
            maudhui: jibu,
            niAI: true,
            wakati: DateTime.now(),
          ));
      _scrollChini();
    }
  }

  void _scrollChini() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historia = ref.watch(mazungumzoProvider);
    final mtumiaji = ref.watch(authServiceProvider).mtumiaji;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: _buildAppBar(context, ref),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F1E), Color(0xFF070B14)],
          ),
        ),
        child: Column(
          children: [
            // Chips za maswali ya haraka (zinaonyeshwa mwanzoni)
            if (historia.isEmpty || (historia.length <= 2))
              _buildSuggestedChips(),

            // Orodha ya ujumbe
            Expanded(
              child: historia.isEmpty && _inasubiri
                  ? _buildLoadingState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: historia.length + (_inasubiri ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == historia.length) {
                          return _TypingBubble(ctrl: _typingCtrl);
                        }
                        final ujumbe = historia[index];
                        return _UjumbeWidget(
                          ujumbe: ujumbe,
                          jina: mtumiaji?.displayName ?? 'Wewe',
                        ).animate().fadeIn(delay: (index * 30).ms).slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            );
                      },
                    ),
            ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFF0F1629),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // AI Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mauzo — AI Msaidizi',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(
                        duration: 2.seconds,
                        color: const Color(0xFF00C853),
                      ),
                  const SizedBox(width: 6),
                  const Text('Mtandaoni — Anajua duka lako',
                      style: TextStyle(
                          color: Color(0xFF00C853),
                          fontFamily: 'Poppins',
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white54),
          tooltip: 'Anza mazungumzo mapya',
          onPressed: () {
            ref.read(mazungumzoProvider.notifier).futa();
            setState(() {
              _inasubiri = false;
              _karibishoLimesha = false;
            });
            _anza();
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _maswaliYaHaraka.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(
              _maswaliYaHaraka[i],
              style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontFamily: 'Poppins',
                  fontSize: 12),
            ),
            backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.1),
            side: BorderSide(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 1),
            onPressed: () => _tumaMujumbe(_maswaliYaHaraka[i]),
          ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
            ),
          ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: Colors.white30),
          const SizedBox(height: 20),
          const Text('Mauzo anachunguza duka lako...',
              style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Poppins',
                  fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Anaangalia bidhaa, mauzo, na maagizo',
              style: TextStyle(
                  color: Colors.white24,
                  fontFamily: 'Poppins',
                  fontSize: 12)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.05), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A2540),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    width: 1),
              ),
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                enabled: !_inasubiri,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Uliza Mauzo chochote...',
                  hintStyle: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Poppins',
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: _tumaMujumbe,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _inasubiri
                ? null
                : () => _tumaMujumbe(_inputCtrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _inasubiri
                    ? const LinearGradient(
                        colors: [Color(0xFF1A2540), Color(0xFF1A2540)])
                    : const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF00C853)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: _inasubiri
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Icon(
                _inasubiri ? Icons.hourglass_empty : Icons.send_rounded,
                color: _inasubiri ? Colors.white24 : Colors.white,
                size: 22,
              ),
            ),
          ).animate().scale(duration: 200.ms),
        ],
      ),
    );
  }
}

// ── Ujumbe mmoja ────────────────────────────────────────────────────

class _UjumbeWidget extends StatelessWidget {
  final UjumbeModel ujumbe;
  final String jina;

  const _UjumbeWidget({required this.ujumbe, required this.jina});

  @override
  Widget build(BuildContext context) {
    final niAI = ujumbe.niAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            niAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (niAI) ...[
            // AI Avatar ndogo
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                ),
              ),
              child: const Center(
                child: Text('M',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  niAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: niAI
                        ? const LinearGradient(
                            colors: [Color(0xFF1A2540), Color(0xFF0F1629)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF00A846)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: niAI
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                      bottomRight: niAI
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                    ),
                    border: niAI
                        ? Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (niAI
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF00C853))
                            .withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    ujumbe.maudhui,
                    style: TextStyle(
                      color: niAI ? Colors.white : Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatWakati(ujumbe.wakati),
                  style: const TextStyle(
                      color: Colors.white24,
                      fontFamily: 'Poppins',
                      fontSize: 10),
                ),
              ],
            ),
          ),
          if (!niAI) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatWakati(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Typing indicator (dots zinaposogea) ────────────────────────────

class _TypingBubble extends StatelessWidget {
  final AnimationController ctrl;

  const _TypingBubble({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2540),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: ctrl,
                  builder: (context, _) {
                    final t = (ctrl.value + i * 0.3) % 1.0;
                    final y = -4.0 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
