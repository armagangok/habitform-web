// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import '/core/core.dart';
import '../purchase.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    required this.isSelected,
    this.isPopular,
    this.discount,
    this.monthlyCalculated,
    required this.package,
    this.isAnnual = false,
  });

  final bool isSelected;
  final bool? isPopular;
  final String? discount;
  final String? monthlyCalculated;
  final Package package;
  final bool isAnnual;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    final priceString = widget.package.storeProduct.priceString;
    final productTitle = widget.package.storeProduct.title;

    final isAnnual = widget.isAnnual;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: widget.isSelected ? 1 : .75,
      child: Card(
        color: context.theme.cardColor.withAlpha(100),
        shape: widget.isSelected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.deepOrangeAccent,
                  width: 4,
                  strokeAlign: 0,
                  style: BorderStyle.solid,
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: context.theme.dividerColor.withValues(alpha: .4),
                  strokeAlign: 0,
                  width: 4,
                ),
              ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: [
                    widget.isSelected
                        ? Icon(
                            CupertinoIcons.circle_fill,
                            color: Colors.deepOrangeAccent,
                            size: 20,
                          ).animate().scale()
                        : Icon(
                            CupertinoIcons.circle,
                            color: context.theme.dividerColor,
                            size: 20,
                          ),
                    SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productTitle.getTitleName.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isAnnual)
                              Text(
                                (widget.package.storeProduct.price * 2).toStringAsFixed(2),
                                textAlign: TextAlign.left,
                                style: context.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (isAnnual) SizedBox(width: 2),
                            if (isAnnual)
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 12,
                              ),
                            if (isAnnual) SizedBox(width: 2),
                            if (isAnnual)
                              Text(
                                widget.package.storeProduct.price.toStringAsFixed(2),
                                textAlign: TextAlign.left,
                                style: context.bodySmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.5) + EdgeInsets.only(left: 15),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            priceString,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    _discountWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _discountWidget() {
    final currentLocale = Localizations.localeOf(context);
    final languageCode = currentLocale.languageCode;
    final isArabic = languageCode == 'ar';

    final discount = widget.discount;

    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Align(
          alignment: isArabic ? Alignment.topLeft : Alignment.topLeft,
          child: Transform.rotate(
            angle: -30 * pi / 180,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.activeOrange,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: widget.discount != null ? 2 : 0, horizontal: 2),
                child: discount != null
                    ? Text(
                        discount,
                        textAlign: TextAlign.center,
                        style: context.bodySmall?.copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    });
  }
}

extension _EasyTitleName on String {
  String get getTitleName {
    if (Platform.isIOS) return this;

    // Remove everything inside parentheses (including nested parentheses)
    String cleanedText = replaceAll(RegExp('\\(.*?\\)'), '');

    // Remove any remaining double quotes and trim whitespace
    cleanedText = cleanedText.replaceAll(')', '').trim();
    cleanedText = cleanedText.replaceAll(' ', '').trim();

    return cleanedText;
  }
}
