import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '/core/core.dart';
import '/models/habit/habit_model.dart';
import 'provider/share_template_provider.dart';
import 'templates/templates.dart';

class ShareHabitPage extends ConsumerStatefulWidget {
  final Habit habit;

  const ShareHabitPage({
    super.key,
    required this.habit,
  });

  @override
  @override
  ConsumerState<ShareHabitPage> createState() => _ShareHabitPageState();
}

class _ShareHabitPageState extends ConsumerState<ShareHabitPage> {
  bool isShareLoading = false;
  final screenshotController = ScreenshotController();

  Future<void> _shareHabitAsImage(BuildContext context) async {
    setState(() {
      isShareLoading = true;
    });

    try {
      // Capture the screenshot using the controller
      final imageFile = await screenshotController.capture(
        pixelRatio: 3.0, // Higher quality image
      );

      if (imageFile == null) {
        throw Exception('Failed to capture screenshot');
      }

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/habit.png').create();
      await file.writeAsBytes(imageFile);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my habit progress!',
      );
    } catch (e) {
      debugPrint('Error sharing habit: $e');
      AppFlushbar.shared.errorFlushbar('${LocaleKeys.common_error.tr()}: $e');
    }

    setState(() {
      isShareLoading = false;
    });
  }

  Future<void> _shareHabitAsText() async {
    final completedDays = widget.habit.completions.values.where((completion) => completion.isCompleted).length;

    final shareText = '''
🎯 ${LocaleKeys.habit_habit_name.tr()}: ${widget.habit.habitName}
✅ ${LocaleKeys.habit_complete.tr()}: $completedDays times
📝 ${LocaleKeys.habit_habit_description.tr()}: ${widget.habit.habitDescription ?? LocaleKeys.common_none.tr()}
    ''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
          title: LocaleKeys.share_share.tr(),
        ),
        child: Stack(
          children: [
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                _TemplateSelector(habit: widget.habit),
                const SizedBox(height: 12),
                SafeArea(
                  bottom: false,
                  child: Screenshot(
                    controller: screenshotController,
                    key: const Key('habit_screenshot'),
                    child: Material(
                      color: Colors.transparent,
                      child: ShareHabitPreview(
                        habit: widget.habit,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.tinted(
                            color: context.primaryContrastingColor,
                            foregroundColor: context.primaryContrastingColor.withValues(alpha: 1),
                            onPressed: isShareLoading
                                ? null
                                : () {
                                    _shareHabitAsImage(context);
                                  },
                            sizeStyle: CupertinoButtonSize.small,
                            child: isShareLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(FontAwesomeIcons.solidFileImage),
                                      const SizedBox(width: 5),
                                      Text(
                                        LocaleKeys.share_share_image.tr(),
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CupertinoButton.tinted(
                            sizeStyle: CupertinoButtonSize.small,
                            onPressed: _shareHabitAsText,
                            color: context.primaryContrastingColor,
                            foregroundColor: context.primaryContrastingColor.withValues(alpha: 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.solidFileLines),
                                SizedBox(width: 5),
                                Text(LocaleKeys.share_share_text.tr()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareHabitPreview extends StatefulWidget {
  final Habit habit;

  const ShareHabitPreview({
    super.key,
    required this.habit,
  });

  @override
  State<ShareHabitPreview> createState() => _ShareHabitPreviewState();
}

class _ShareHabitPreviewState extends State<ShareHabitPreview> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() async {
    // Wait for the widget to be fully built and laid out
    await Future.delayed(Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void initState() {
    super.initState();

    // Only auto-scroll in preview mode, not screenshot mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(widget.habit.colorCode);
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: RepaintBoundary(
            child: ShareTemplateSwitcher(
              habit: widget.habit,
              controller: _scrollController,
              accentColor: accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateSelector extends ConsumerWidget {
  final Habit habit;

  const _TemplateSelector({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(shareTemplateProvider);
    final selected = provider.selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CupertinoSegmentedControl<int>(
          groupValue: selected,
          selectedColor: Color(habit.colorCode),
          unselectedColor: Color(habit.colorCode).withValues(alpha: .3),
          borderColor: Color(habit.colorCode).withValues(alpha: .7),
          pressedColor: Color(habit.colorCode).withValues(alpha: .5),
          padding: const EdgeInsets.all(4),
          children: {
            for (int i = 0; i < provider.templates.length; i++)
              i: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  provider.templates[i].title,
                  style: TextStyle(
                    color: selected == i ? Color(habit.colorCode).colorRegardingToBrightness : context.primaryContrastingColor.withValues(alpha: .7),
                  ),
                ),
              ),
          },
          onValueChanged: (i) => ref.read(shareTemplateProvider.notifier).select(i),
        ),
      ),
    );
  }
}
