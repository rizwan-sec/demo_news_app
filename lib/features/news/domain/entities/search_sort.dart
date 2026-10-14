enum SearchSort {
  relevancy('relevancy', 'Relevance'),
  publishedAt('publishedAt', 'Latest');

  const SearchSort(this.apiValue, this.label);

  final String apiValue;
  final String label;
}