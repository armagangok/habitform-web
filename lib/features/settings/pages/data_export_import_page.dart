import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../services/csv_service/csv_service.dart';

class DataExportImportPage extends ConsumerStatefulWidget {
  const DataExportImportPage({super.key});

  @override
  ConsumerState<DataExportImportPage> createState() => _DataExportImportPageState();
}

class _DataExportImportPageState extends ConsumerState<DataExportImportPage> {
  final _csvService = CSVService.instance;
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    try {
      setState(() {
        _isExporting = true;
      });

      final filePath = await _csvService.exportHabitsToCSV();
      await _csvService.shareCSVFile(filePath);

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(LocaleKeys.common_Information.tr()),
            content: Text(LocaleKeys.settings_export_success.tr()),
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
      if (mounted) {
        setState(() {
          _isExporting = false;
        });

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
  }

  Future<void> _importData() async {
    try {
      setState(() {
        _isImporting = true;
      });

      final importedCount = await _csvService.importHabitsFromCSV();

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.settings_data_export_import.tr(),
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle_fill,
                            color: context.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            LocaleKeys.settings_about_data_management.tr(),
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        LocaleKeys.settings_data_management_description.tr(),
                        style: context.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Export section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_down_doc_fill,
                            color: CupertinoColors.systemGreen,
                          ),
                          SizedBox(width: 8),
                          Text(
                            LocaleKeys.settings_export_data.tr(),
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        LocaleKeys.settings_export_description.tr(),
                        style: context.bodyMedium,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: Colors.deepOrangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isExporting ? null : _exportData,
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
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Import section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_up_doc_fill,
                            color: CupertinoColors.systemBlue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            LocaleKeys.settings_import_data.tr(),
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        LocaleKeys.settings_import_description.tr(),
                        style: context.bodyMedium,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: Colors.deepOrangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isImporting ? null : _importData,
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
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
