import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../export_import_data/csv_service.dart';
import 'setting_item.dart';

class DataExportImportWidget extends ConsumerStatefulWidget {
  const DataExportImportWidget({super.key});

  @override
  ConsumerState<DataExportImportWidget> createState() => _DataExportImportWidgetState();
}

class _DataExportImportWidgetState extends ConsumerState<DataExportImportWidget> {
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
    return Column(
      children: [
        CupertinoListTile(
          leading: const SettingLeadingWidget(
            iconData: CupertinoIcons.arrow_down_doc_fill,
            cardColor: CupertinoColors.systemGreen,
          ),
          title: Text(LocaleKeys.settings_export_data.tr()),
          trailing: _isExporting ? const CupertinoActivityIndicator() : const CupertinoListTileChevron(),
          onTap: _isExporting ? null : _exportData,
        ),
        CupertinoListTile(
          leading: const SettingLeadingWidget(
            iconData: CupertinoIcons.arrow_up_doc_fill,
            cardColor: CupertinoColors.systemBlue,
          ),
          title: Text(LocaleKeys.settings_import_data.tr()),
          trailing: _isImporting ? const CupertinoActivityIndicator() : const CupertinoListTileChevron(),
          onTap: _isImporting ? null : _importData,
        ),
      ],
    );
  }
}
