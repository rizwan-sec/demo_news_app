import 'package:flutter/material.dart';

const newsCategories = [
  'general',
  'business',
  'technology',
  'sports',
  'health',
  'science',
  'entertainment',
];

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  String _label(String c) => c[0].toUpperCase() + c.substring(1);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: newsCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = newsCategories[i];
          return ChoiceChip(
            label: Text(_label(c)),
            selected: c == selected,
            onSelected: (_) => onSelected(c),
          );
        },
      ),
    );
  }
}