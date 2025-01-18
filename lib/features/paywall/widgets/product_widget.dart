import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart';

class ProductWidget extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final bool isPopular;

  const ProductWidget({
    super.key,
    required this.package,
    required this.isSelected,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final monthlyPrice = (product.price / 12).toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 150,
      child: Card(
        color: isSelected ? context.primary : context.cupertinoTheme.scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPopular) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LocaleKeys.subscription_popular.tr(),
                    style: context.bodySmall?.copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
              Text(
                package.packageType == PackageType.annual ? LocaleKeys.subscription_yearly.tr() : LocaleKeys.subscription_monthly.tr(),
                style: context.titleMedium?.copyWith(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              if (package.packageType == PackageType.annual) ...[
                Text(
                  "${product.currencyCode} $monthlyPrice/${LocaleKeys.subscription_month.tr()}",
                  style: context.bodySmall?.copyWith(
                    color: isSelected ? Colors.white.withOpacity(0.8) : null,
                  ),
                ),
                Text(
                  "${LocaleKeys.subscription_billed.tr()} ${product.currencyCode} ${product.price}/${LocaleKeys.subscription_year.tr()}",
                  style: context.bodySmall?.copyWith(
                    color: isSelected ? Colors.white.withOpacity(0.8) : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else
                Text(
                  "${product.currencyCode} ${product.price}/${LocaleKeys.subscription_month.tr()}",
                  style: context.bodySmall?.copyWith(
                    color: isSelected ? Colors.white.withOpacity(0.8) : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
