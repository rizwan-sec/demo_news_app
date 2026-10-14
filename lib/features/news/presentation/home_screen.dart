import 'package:demo_news_app/features/news/presentation/widgets/article_card.dart';
import 'package:demo_news_app/features/news/presentation/widgets/category_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/presentation/screens/favorites_screen.dart';
import '../../search/presentation/screens/search_screen.dart';
import '../providers/news_provider.dart';
import 'article_details_screen.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(newsFeedProvider.notifier).loadMore();
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<NewsFeedState>(newsFeedProvider, (prev, next) {
      if (next.error != null &&
          next.articles.isNotEmpty &&
          prev?.error != next.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final feed = ref.watch(newsFeedProvider);
    final notifier = ref.read(newsFeedProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          CategoryChips(
            selected: feed.category,
            onSelected: (c) {
              notifier.selectCategory(c);
              if (_scroll.hasClients) _scroll.jumpTo(0);
            },
          ),
          Expanded(child: _buildBody(feed, notifier)),
        ],
      ),
    );
  }

  Widget _buildBody(NewsFeedState feed, NewsFeedNotifier notifier) {
    if (feed.isLoading && feed.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (feed.error != null && feed.articles.isEmpty) {
      return ErrorView(message: feed.error!, onRetry: notifier.loadInitial);
    }
    if (feed.articles.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: feed.articles.length + (feed.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= feed.articles.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: feed.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox(height: 24),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
        child: ArticleCard(
          article: feed.articles[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: feed.articles[i]),
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}