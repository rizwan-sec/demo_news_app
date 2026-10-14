import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../news/domain/entities/search_sort.dart';
import '../../../news/presentation/article_details_screen.dart';
import '../../../news/presentation/widgets/article_card.dart';
import '../../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Restore the last query so the text field matches the saved state.
    _controller = TextEditingController(text: ref.read(searchProvider).query);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Failure while a list is already visible (e.g. next page) -> snackbar.
    ref.listen<SearchState>(searchProvider, (prev, next) {
      if (next.error != null &&
          next.articles.isNotEmpty &&
          prev?.error != next.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final search = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onChanged: notifier.onQueryChanged,
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                notifier.onQueryChanged('');
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SortChips(selected: search.sort, onSelected: notifier.setSort),
          Expanded(child: _buildBody(search, notifier)),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState search, SearchNotifier notifier) {
    if (!search.hasQuery) {
      return const _Message(
        icon: Icons.search,
        title: 'Search for news',
        subtitle: 'Type at least 2 characters.',
      );
    }
    if (search.isLoading && search.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (search.error != null && search.articles.isEmpty) {
      return ErrorView(message: search.error!, onRetry: notifier.retry);
    }
    if (search.articles.isEmpty) {
      return _Message(
        icon: Icons.search_off,
        title: 'No results',
        subtitle: 'Nothing found for "${search.query}".',
      );
    }

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(12),
      itemCount: search.articles.length + (search.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i >= search.articles.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: search.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox(height: 24),
            ),
          );
        }
        final article = search.articles[i];
        return ArticleCard(
          article: article,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: article),
            ),
          ),
        );
      },
    );
  }
}

class _SortChips extends StatelessWidget {
  const _SortChips({required this.selected, required this.onSelected});

  final SearchSort selected;
  final ValueChanged<SearchSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final sort in SearchSort.values) ...[
            ChoiceChip(
              label: Text(sort.label),
              selected: sort == selected,
              onSelected: (_) => onSelected(sort),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}