import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/widgets/my_list_tile.dart';

import '../../core/core.dart';
import '../home/provider/home_provider.dart';
import '../purchase/providers/purchase_provider.dart';
import 'csv_service.dart';
import 'permission_helper.dart';

class DataExportImportPage extends ConsumerStatefulWidget {
  const DataExportImportPage({super.key});

  @override
  ConsumerState<DataExportImportPage> createState() => _DataExportImportPageState();
}

class _DataExportImportPageState extends ConsumerState<DataExportImportPage> {
  final _csvService = CSVService.instance;
  final _permissionHelper = PermissionHelper();

  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    try {
      setState(() {
        _isExporting = true;
      });

      await _csvService.exportHabitsToCSV();
    } catch (e) {
      if (mounted) {
        // Show error message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(LocaleKeys.common_error.tr()),
            content: Text("${LocaleKeys.settings_export_error.tr()}: $e"),
            actions: [
              CupertinoDialogAction(
                child: Text(LocaleKeys.common_ok.tr()),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _importData() async {
    try {
      // Check for storage permissions first
      final hasPermission = await _permissionHelper.checkAndRequestStoragePermission(context);
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return;
      }

      debugPrint('Starting CSV import process...');
      setState(() {
        _isImporting = true;
      });

      final importedCount = await _csvService.importHabitsFromCSV();
      debugPrint('CSV import completed. Imported count: $importedCount');

      if (importedCount > 0) {
        // Ana ekran verilerini yenile
        ref.invalidate(homeProvider);

        // Verileri yeniden yükle
        await ref.read(homeProvider.notifier).fetchHabits();
      }

      if (mounted) {
        setState(() {
          _isImporting = false;
        });

        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(LocaleKeys.common_Information.tr()),
            content: Text(
              importedCount > 0 ? "${LocaleKeys.settings_import_success.tr()}: $importedCount ${LocaleKeys.settings_habits_imported.tr()}" : LocaleKeys.settings_no_habits_imported.tr(),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(LocaleKeys.common_ok.tr()),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _importData: $e');
      if (mounted) {
        setState(() {
          _isImporting = false;
        });

        // Show error message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(LocaleKeys.common_error.tr()),
            content: Text("${LocaleKeys.settings_import_error.tr()}: $e"),
            actions: [
              CupertinoDialogAction(
                child: Text(LocaleKeys.common_ok.tr()),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showPaywallPage() {
    navigator.navigateTo(
      path: KRoute.prePaywall,
      data: {'isFromOnboarding': false, 'isFromSettings': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);
    final isProUser = purchaseState.value?.isSubscriptionActive ?? false;

    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.settings_data_export_import.tr(),
        closeButtonPosition: CloseButtonPosition.left,
        middle: Text(LocaleKeys.settings_data_export_import.tr()),
      ),
      child: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Info section
            CupertinoListSection.insetGrouped(
              header: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    color: context.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    LocaleKeys.settings_about_data_management.tr(),
                  ),
                ],
              ),
              children: [
                MyListTile(
                  title: LocaleKeys.settings_data_management_description.tr(),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Export section
            Stack(
              children: [
                CupertinoListSection.insetGrouped(
                  header: Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_doc_fill,
                        color: CupertinoColors.systemGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        LocaleKeys.settings_export_data.tr(),
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  footer: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: isProUser ? (_isExporting ? null : _exportData) : _showPaywallPage,
                      child: _isExporting
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 8),
                                Text(LocaleKeys.settings_exporting.tr()),
                              ],
                            )
                          : Text(
                              LocaleKeys.settings_export_data.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  children: [
                    MyListTile(
                      title: LocaleKeys.settings_export_description.tr(),
                    ),
                  ],
                ),
                if (!isProUser)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellowAccent,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 24),

            // Import section
            Stack(
              children: [
                CupertinoListSection.insetGrouped(
                  header: Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_up_doc_fill,
                        color: CupertinoColors.systemBlue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        LocaleKeys.settings_import_data.tr(),
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  footer: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: isProUser ? (_isImporting ? null : _importData) : _showPaywallPage,
                      child: _isImporting
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 8),
                                Text(LocaleKeys.settings_importing.tr()),
                              ],
                            )
                          : Text(
                              LocaleKeys.settings_import_data.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  children: [
                    MyListTile(
                      title: LocaleKeys.settings_import_description.tr(),
                    ),
                  ],
                ),
                if (!isProUser)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellowAccent,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
