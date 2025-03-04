// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import '/core/core.dart';
import '../purchase.dart';

class MonthlyPackage extends StatefulWidget {
  const MonthlyPackage({
    super.key,
    required this.isSelected,
    required this.package,
  });

  final Package package;
  final bool isSelected;

  @override
  State<MonthlyPackage> createState() => _MonthlyPackageState();
}

class _MonthlyPackageState extends State<MonthlyPackage> {
  @override
  Widget build(BuildContext context) {
    final priceString = widget.package.storeProduct.priceString;
    final productTitle = widget.package.storeProduct.title;

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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _EasyTitleName on String {
  String get getTitleName {
    if (Platform.isIOS) return this;

    String cleanedText = replaceAll(RegExp('\\(.*?\\)'), '');

    cleanedText = cleanedText.replaceAll(')', '').trim();
    cleanedText = cleanedText.replaceAll(' ', '').trim();

    return cleanedText;
  }
}
