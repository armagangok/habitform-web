import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart' hide LocaleKeys;
import '/core/widgets/blur_widget.dart';
import '/core/widgets/body_text.dart';
import '/core/widgets/setting_leading.dart';
import '../../../core/helpers/url_laucher/url_launcher.dart';
import '../../translation/constants/locale_keys.g.dart';
import '../bloc/paywall_bloc.dart';
import 'product_widget.dart';

class PaywallWidget extends StatefulWidget {
  const PaywallWidget({super.key});

  @override
  State<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> with SingleTickerProviderStateMixin {
  int selectedIndex = 1;
  late Package selectedPackage;

  final List<FeatureModel> featureList = [
    FeatureModel(
      "LocaleKeys.infiniteTasks.tr()",
      CupertinoIcons.square_list_fill,
      "LocaleKeys.createUnlimitedPomodoroTasksToManage.tr()",
      Colors.blue.shade600,
    ),
    FeatureModel(
      "LocaleKeys.infiniteProjects.tr()",
      CupertinoIcons.folder_fill_badge_plus,
      "LocaleKeys.organizeYourTasksUnderUnlimited.tr()",
      Colors.red.shade600,
    ),
    FeatureModel(
      "LocaleKeys.statistics.tr()",
      CupertinoIcons.graph_square_fill,
      "LocaleKeys.trackYourProgressWithDetailedPomodoro.tr()",
      Colors.orange.shade600,
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PaywallBloc>().add(InitializePaywallEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaywallBloc, PaywallState>(
      builder: (context, state) {
        if (state is PaywallLoading) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (state is PaywallLoaded) {
          final availablePackages = state.offerings?.current?.availablePackages;
          if (availablePackages != null && availablePackages.isNotEmpty) {
            selectedPackage = availablePackages.last;
            selectedIndex = availablePackages.indexOf(availablePackages.last);
          }

          return CupertinoPageScaffold(
            navigationBar: _navBar(context),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: BodySmall(text: "LocaleKeys.accessAllTheAdvantages.tr()"),
                        ),
                        SizedBox(height: 8),
                        _productSection(state),
                        SizedBox(height: 40),
                        Text(
                          "LocaleKeys.whatYouWillUnlock.tr()",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          physics: ClampingScrollPhysics(),
                          itemCount: featureList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final feature = featureList[index];
                            return CupertinoListTile(
                              padding: EdgeInsets.only(bottom: 15, right: 15),
                              leadingSize: 40,
                              leading: SettingLeadingWidget(
                                cardColor: feature.color.withAlpha((0.8 * 255).toInt()),
                                padding: 6,
                                iconData: feature.widget,
                              ),
                              title: Text(
                                feature.name,
                                style: TextStyle(
                                  color: feature.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                feature.description,
                                maxLines: 3,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
                _continueButton(state),
              ],
            ),
          );
        }

        if (state is PaywallError) {
          return Center(child: Text(state.message));
        }

        return SizedBox.shrink();
      },
    );
  }

  CupertinoNavigationBar _navBar(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Align(
        widthFactor: 1,
        child: SizedBox(
          height: 28,
          width: 28,
          child: CupertinoButton(
            color: context.iconTheme.color?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(90),
            padding: EdgeInsets.zero,
            onPressed: navigator.pop,
            child: FittedBox(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(360),
                ),
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: context.iconTheme.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Pomo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              children: [
                TextSpan(
                  text: 'Done  ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Text(
            "Pro",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          )
        ],
      ),
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      transitionBetweenRoutes: false,
    );
  }

  Widget _continueButton(PaywallLoaded state) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomBlurWidget(
        blurValue: 20,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: state.isPurchasing
                      ? null
                      : () async {
                          HapticFeedback.heavyImpact();
                          context.read<PaywallBloc>().add(
                                PurchaseProductEvent(selectedPackage: selectedPackage),
                              );
                        },
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: context.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: state.isPurchasing
                              ? CupertinoActivityIndicator(color: Colors.white)
                              : Text(
                                  "LocaleKeys.common_continue.tr()",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => UrlLauncherHelper.openTermsOfUse(),
                    child: Text(
                      LocaleKeys.settings_terms.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Text(" • "),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => UrlLauncherHelper.openPrivacyPolicy(),
                    child: Text(
                      LocaleKeys.settings_privacy.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.read<PaywallBloc>().add(RestorePurchasesEvent());
                },
                child: Text(
                  LocaleKeys.subscription_restore.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productSection(PaywallLoaded state) {
    final offerings = state.offerings;
    if (offerings == null) return SizedBox.shrink();

    final packages = offerings.current?.availablePackages;
    if (packages == null) return SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
                selectedPackage = package;
              });
            },
            child: ProductWidget(
              package: package,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }
}

class FeatureModel {
  final IconData widget;
  final String name;
  final String description;
  final Color color;

  FeatureModel(this.name, this.widget, this.description, this.color);
}
