import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../favorites/providers/favorites_provider.dart';
import '../domain/entities/article.dart';


class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  // NewsAPI truncates `content` and ends it with "[+1234 chars]".
  static final _truncatedSuffix = RegExp(r'\s*\[\+\d+ chars\]$');

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref, bool wasFav) async {
    await ref.read(favoritesProvider.notifier).toggle(article);
    if (!context.mounted) return;
    _showMessage(
      context,
      wasFav ? 'Removed from favorites' : 'Saved to favorites',
    );
  }

  Future<void> _openFullArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    final opened = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showMessage(context, 'Could not open the article link.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isFav = ref.watch(isFavoriteProvider(article.url));
    final date = article.publishedAt;
    final content = article.content?.replaceAll(_truncatedSuffix, '').trim();

    final meta = [
      if (article.sourceName != null) article.sourceName!,
      if (article.author != null && article.author!.isNotEmpty) article.author!,
      if (date != null) DateFormat('MMM d, y').format(date.toLocal()),
    ].join(' • ');

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: isFav ? 'Remove from favorites' : 'Save to favorites',
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? Colors.red : null,
            onPressed: () => _toggleFavorite(context, ref, isFav),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.black12),
                  errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(meta, style: textTheme.bodySmall),
                  ],
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(article.description!, style: textTheme.titleMedium),
                  ],
                  if (content != null &&
                      content.isNotEmpty &&
                      content != article.description) ...[
                    const SizedBox(height: 16),
                    Text(content, style: textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openFullArticle(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read full article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}