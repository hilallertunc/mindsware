import 'package:flutter/material.dart';
import '../data/tips_repository.dart';
import '../models/tip_card.dart';
import 'tip_detail_page.dart';

class TipsListPage extends StatelessWidget {
  const TipsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öneriler & Makaleler'),
        centerTitle: false,
      ),
      backgroundColor: cs.surfaceVariant.withOpacity(.25),
      body: FutureBuilder<List<TipCardModel>>(
        future: const TipsRepository().loadTips(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final items = snap.data ?? const <TipCardModel>[];
          if (items.isEmpty) {
            return const Center(child: Text('Henüz öneri yok.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final tip = items[i];
              return _TipCardTile(
                tip: tip,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 260),
                      pageBuilder: (_, __, ___) => TipDetailPage(tip: tip),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TipCardTile extends StatelessWidget {
  final TipCardModel tip;
  final VoidCallback onTap;
  const _TipCardTile({required this.tip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.surface, cs.surfaceVariant.withOpacity(.35)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // → Görsel (ikon yerine)
            Hero(
              tag: 'tip:${tip.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    tip.resolvedImagePath,
                    fit: BoxFit.cover,
                    // Eğer asset yoksa ikonla şık bir fallback:
                    errorBuilder: (_, __, ___) => Container(
                      color: cs.primary.withOpacity(.08),
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined, color: cs.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // kategori pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.primary.withOpacity(.25)),
                    ),
                    child: Text(
                      tip.category,
                      style: text.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: text.bodySmall?.color,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
