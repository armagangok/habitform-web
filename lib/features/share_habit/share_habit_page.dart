import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '/core/core.dart';
import '/models/habit/habit_model.dart';
import '../habit_detail/widget/habit_data_widget.dart';

class ShareHabitPage extends StatefulWidget {
  final Habit habit;

  const ShareHabitPage({
    super.key,
    required this.habit,
  });

  @override
  State<ShareHabitPage> createState() => _ShareHabitPageState();
}

class _ShareHabitPageState extends State<ShareHabitPage> {
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
                SizedBox(height: 20),
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
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(widget.habit.colorCode).withValues(alpha: .8),
              Color(widget.habit.colorCode).withValues(alpha: .9),
              Color(widget.habit.colorCode).withValues(alpha: 1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.habit.habitName,
                                    style: context.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // if (widget.habit.habitDescription != null) ...[
                                  //   Text(
                                  //     widget.habit.habitDescription!,
                                  //     style: context.bodyMedium,
                                  //   ),
                                  // ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        HabitDataWidget(habit: widget.habit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              bottom: 10,
              left: 30,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Assets.app.appLogoDark.image(
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "HabitRise",
                      style: context.bodySmall.copyWith(
                        color: Color(widget.habit.colorCode).colorRegardingToBrightness,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
