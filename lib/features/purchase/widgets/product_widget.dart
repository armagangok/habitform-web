// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart';
import '../providers/purchase_provider.dart';
import '../purchase.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    this.isPopular,
    required this.discount,
    this.monthlyCalculated,
    required this.package,
    this.onTap,
  });

  final bool? isPopular;
  final String discount;
  final String? monthlyCalculated;
  final Package package;

  final VoidCallback? onTap;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    final priceString = widget.package.storeProduct.priceString;
    final productTitle = widget.package.storeProduct.title;

    return Consumer(builder: (context, ref, child) {
      final paywallState = ref.watch(purchaseProvider);

      final isPurchasing = paywallState.value?.isPurchasing ?? false;
      return CustomButton(
        onPressed: isPurchasing ? null : widget.onTap,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: isPurchasing ? 0.35 : 1,
          child: Card(
            color: Colors.deepOrangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                productTitle.getTitleName.toUpperCase(),
                                style: context.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (widget.package.storeProduct.price * 2).toStringAsFixed(2),
                                    textAlign: TextAlign.left,
                                    style: context.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.white,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.arrow_right,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    widget.package.storeProduct.price.toStringAsFixed(2),
                                    textAlign: TextAlign.left,
                                    style: context.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              if (isPurchasing) const CupertinoActivityIndicator(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.5) + EdgeInsets.only(left: 15),
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  priceString,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
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
          ),
        ),
      );
    });
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
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Text(
                  discount,
                  textAlign: TextAlign.center,
                  style: context.bodySmall?.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
