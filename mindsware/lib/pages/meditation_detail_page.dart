import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';

class MeditationDetailScreen extends StatefulWidget {
  final String title;
  const MeditationDetailScreen({super.key, required this.title});

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  bool _hasError = false;

  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final assetPath = _getAudioAsset(widget.title);
      if (assetPath != null) {
        await _player.setAsset(assetPath);
        setState(() => _audioReady = true);
      }
    } catch (_) {
      // asset yoksa sessiz geç
      setState(() => _audioReady = false);
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _getDescription(String title) {
    switch (title.trim().toLowerCase()) {
      case 'odaklanma':
        return 'Dikkatin dağıldığında verimliliğin düşer. Bu meditasyon zihnini toparlamana ve şu ana odaklanmana yardımcı olur.';
      case 'derin uyku':
        return 'Derin ve kaliteli uyku zihinsel sağlığın temelidir. Bu meditasyon bedenini ve zihnini huzurlu bir uykuya hazırlar.';
      case 'kaygı':
        return 'Günlük stres ve kaygıyı azaltmak için nefes ve farkındalık egzersizleri. Zihnini sakinleştir, bedeni gevşet.';
      case 'mutluluk':
        return 'Şükran ve olumlu duygu odaklı kısa bir pratik. Gününe hafiflik ve neşe kat.';
      default:
        return 'Bu meditasyon, günlük yaşamın her anında zihinsel rahatlık ve denge bulmana yardımcı olmak için hazırlandı.';
    }
  }

  String _getAnimationPath(String title) {
    switch (title.trim().toLowerCase()) {
      case 'odaklanma':
        return 'assets/animations/focus.json';
      case 'derin uyku':
        return 'assets/animations/sleep.json';
      case 'kaygı':
        return 'assets/animations/relax.json';
      case 'mutluluk':
        return 'assets/animations/breathe.json';
      default:
        return 'assets/animations/anim1.json';
    }
  }

  String? _getAudioAsset(String title) {
    switch (title.trim().toLowerCase()) {
      case 'odaklanma':
        return 'assets/audio/focus.mp3';
      case 'derin uyku':
        return 'assets/audio/sleep.mp3';
      case 'kaygı':
        return 'assets/audio/meditation.mp3';
      case 'mutluluk':
        return 'assets/audio/calm.mp3';
      default:
        return null; // fallback: sessiz
    }
  }

  IconData _getFallbackIcon(String title) {
    switch (title.trim().toLowerCase()) {
      case 'odaklanma':
        return Icons.center_focus_strong;
      case 'derin uyku':
        return Icons.bedtime_outlined;
      case 'kaygı':
        return Icons.spa_outlined;
      case 'mutluluk':
        return Icons.emoji_emotions_outlined;
      default:
        return Icons.self_improvement;
    }
  }

  Color _getIconColor(String title) {
    switch (title.trim().toLowerCase()) {
      case 'odaklanma':
        return const Color(0xFF5B8B79);
      case 'derin uyku':
        return const Color(0xFFb6dbf7);
      case 'kaygı':
        return const Color(0xFF819A91);
      case 'mutluluk':
        return const Color(0xFFFFB74D);
      default:
        return const Color(0xFF3DD892);
    }
  }

  Widget _buildAnimationWidget() {
    final animationPath = _getAnimationPath(widget.title);

    return SizedBox(
      width: 300,
      height: 300,
      child: _hasError
          ? _buildFallbackIcon()
          : Lottie.asset(
              animationPath,
              width: 400,
              height: 400,
              fit: BoxFit.contain,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                _lottieController.repeat();
              },
    
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_hasError) {
                    setState(() => _hasError = true);
                  }
                });
                return _buildFallbackIcon();
              },
            ),
    );
  }

  Widget _buildFallbackIcon() {
    final color = _getIconColor(widget.title);
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.25), width: 2),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.85, end: 1.15),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Icon(_getFallbackIcon(widget.title), size: 120, color: color),
          );
        },
      ),
    );
  }

  Future<void> _togglePlay() async {
    if (!_audioReady) {
      final accent = _getIconColor(widget.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ses kaydı bulunamadı veya yüklenemedi.'),
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getIconColor(widget.title);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_border, color: Color(0xFF9F0505), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // title + desc
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - value)),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - value)),
                      child: Text(
                        _getDescription(widget.title),
                        style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // lottie
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.5 + 0.5 * value,
                          child: _buildAnimationWidget(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // süre etiketi
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.15), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, color: Colors.black, size: 16),
                      SizedBox(width: 8),
                      Text('10 dakika', style: TextStyle(color: Colors.black, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // play/pause
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.9, end: 1.1),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
                            boxShadow: [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
