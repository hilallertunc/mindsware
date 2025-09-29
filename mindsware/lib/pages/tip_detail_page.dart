import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/tip_card.dart';

class TipDetailPage extends StatelessWidget {
  final TipCardModel tip;
  const TipDetailPage({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(tip.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // → Görsel (hero ile)
          Hero(
            tag: 'tip:${tip.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  tip.resolvedImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    alignment: Alignment.center,
                    color: cs.primary.withOpacity(.08),
                    child: Icon(Icons.image_outlined, size: 48, color: cs.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kategori rozeti
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tip.category,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Detay metni
          Text(tip.detail, style: text.bodyLarge?.copyWith(height: 1.55)),
          const SizedBox(height: 16),

          if (tip.tips.isNotEmpty) ...[
            Text('Uygulanabilir İpuçları',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...tip.tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: cs.primary)),
                    Expanded(child: Text(t, style: text.bodyMedium)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (tip.sources.isNotEmpty) ...[
            Text('Kaynaklar',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...tip.sources.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () async {
                    if (s.startsWith('http')) {
                      await launchUrlString(s, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s,
                          style: text.bodyMedium?.copyWith(
                            decoration: s.startsWith('http')
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            color: s.startsWith('http') ? cs.primary : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
