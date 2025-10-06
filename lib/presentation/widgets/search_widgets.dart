import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import 'common_widgets.dart';

/// Advanced Search Filter Chip
class AdvancedFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final String? badge;
  final bool showRemove;

  const AdvancedFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.badge,
    this.showRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: isSelected ? Border.all(color: color, width: 1.5) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (showRemove && isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.close,
                    size: 14,
                    color: color,
                  ),
                ],
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interactive Price Range Slider
class InteractivePriceRangeSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double currentMin;
  final double currentMax;
  final Function(double min, double max) onChanged;
  final String currency;

  const InteractivePriceRangeSlider({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.currentMin,
    required this.currentMax,
    required this.onChanged,
    this.currency = 'ر.س',
  });

  @override
  State<InteractivePriceRangeSlider> createState() => _InteractivePriceRangeSliderState();
}

class _InteractivePriceRangeSliderState extends State<InteractivePriceRangeSlider> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.currentMin, widget.currentMax);
  }

  @override
  void didUpdateWidget(InteractivePriceRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMin != widget.currentMin ||
        oldWidget.currentMax != widget.currentMax) {
      _currentRange = RangeValues(widget.currentMin, widget.currentMax);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Price display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentRange.start.toInt()} ${widget.currency}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                'نطاق السعر',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentRange.end.toInt()} ${widget.currency}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Range slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 12),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
          ),
          child: RangeSlider(
            values: _currentRange,
            min: widget.minValue,
            max: widget.maxValue,
            divisions: 100,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRange = values;
              });
              widget.onChanged(values.start, values.end);
            },
          ),
        ),

        // Quick price options
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPriceOption('تحت 100', 0, 100),
            _buildQuickPriceOption('100 - 500', 100, 500),
            _buildQuickPriceOption('500 - 1000', 500, 1000),
            _buildQuickPriceOption('1000 - 5000', 1000, 5000),
            _buildQuickPriceOption('فوق 5000', 5000, widget.maxValue),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPriceOption(String label, double min, double max) {
    final isSelected = _currentRange.start <= min && _currentRange.end >= max;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRange = RangeValues(min, max);
        });
        widget.onChanged(min, max);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary)
              : Border.all(color: AppColors.outline.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Search History Item Widget
class SearchHistoryItem extends StatelessWidget {
  final String query;
  final DateTime timestamp;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool showTime;

  const SearchHistoryItem({
    super.key,
    required this.query,
    required this.timestamp,
    required this.onTap,
    required this.onRemove,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          query,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: showTime ? Text(
          _formatTimestamp(timestamp),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondary.withOpacity(0.6),
                size: 20,
              ),
              splashRadius: 20,
            ),
            Icon(
              Icons.arrow_back_ios,
              color: AppColors.textSecondary.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}

/// Search Suggestion Item
class SearchSuggestionItem extends StatelessWidget {
  final String suggestion;
  final String query;
  final VoidCallback onTap;
  final IconData leadingIcon;

  const SearchSuggestionItem({
    super.key,
    required this.suggestion,
    required this.query,
    required this.onTap,
    this.leadingIcon = Icons.search_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: AppColors.primary,
        size: 20,
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          children: _highlightQuery(suggestion, query),
        ),
      ),
      trailing: Icon(
        Icons.call_made_rounded,
        color: AppColors.textSecondary.withOpacity(0.4),
        size: 16,
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  List<TextSpan> _highlightQuery(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}

/// Filter Section Header
class FilterSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? description;
  final bool isCollapsed;
  final VoidCallback? onToggle;
  final Widget? action;

  const FilterSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.description,
    this.isCollapsed = false,
    this.onToggle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
          if (onToggle != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isCollapsed ? Icons.expand_more : Icons.expand_less,
                color: AppColors.textSecondary,
              ),
              splashRadius: 20,
            ),
          ],
        ],
      ),
    );
  }
}

/// Active Filters Summary
class ActiveFiltersSummary extends StatelessWidget {
  final List<String> activeFilters;
  final VoidCallback onClearAll;
  final Function(String) onRemoveFilter;

  const ActiveFiltersSummary({
    super.key,
    required this.activeFilters,
    required this.onClearAll,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'الفلاتر النشطة (${activeFilters.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 1,
            runSpacing: 2,
            children: activeFilters.map((filter) =>
                AdvancedFilterChip(
                  label: filter,
                  isSelected: true,
                  showRemove: true,
                  onTap: () => onRemoveFilter(filter),
                ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

/// Search Results Header
class SearchResultsHeader extends StatelessWidget {
  final int totalResults;
  final String query;
  final String? filtersSummary;
  final bool isLoading;

  const SearchResultsHeader({
    super.key,
    required this.totalResults,
    required this.query,
    this.filtersSummary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      if (isLoading) ...[
                        const TextSpan(text: 'جاري البحث عن '),
                        TextSpan(
                          text: '"$query"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: '...'),
                      ] else ...[
                        TextSpan(
                          text: '$totalResults',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' نتيجة للبحث عن '),
                        TextSpan(
                          text: '"$query"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
            ],
          ),
          if (filtersSummary != null && filtersSummary!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'الفلاتر: $filtersSummary',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty Search State with Suggestions
class EmptySearchState extends StatelessWidget {
  final String query;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;

  const EmptySearchState({
    super.key,
    required this.query,
    required this.suggestions,
    required this.onSuggestionTap,
    this.onClearFilters,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Empty state icon and message
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'لا توجد نتائج',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'لم نجد أي منتجات تطابق '),
                TextSpan(
                  text: '"$query"',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          if (hasActiveFilters) ...[
            const SizedBox(height: 24),
            ShamraButton(
              width: double.infinity,
              text: 'مسح الفلاتر والمحاولة مرة أخرى',
              onPressed: onClearFilters,
              isOutlined: true,
              icon: Icons.filter_alt_off_rounded,
            ),
          ],

          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'اقتراحات للبحث:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: suggestions.map((suggestion) =>
                  ShamraChip(
                    label: suggestion,
                    onTap: () => onSuggestionTap(suggestion),
                    icon: Icons.lightbulb_outline_rounded,
                  ),
              ).toList(),
            ),
          ],

          const SizedBox(height: 32),

          Text(
            'نصائح للبحث:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'جرب كلمات أخرى',
              'استخدم أسماء أعم',
              'تحقق من التهجئة',
              'ابحث بالإنجليزية',
              'قلل من الفلاتر',
            ].map((tip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Text(
                tip,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}