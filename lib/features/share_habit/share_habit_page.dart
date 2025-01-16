import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '/core/core.dart';
import '../../models/models.dart';

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

  Future<void> _shareHabitAsImage(ShareHabitPreview previewWidget, BuildContext contextFromWidget) async {
    setState(() {
      isShareLoading = true;
    });

    try {
      final screenshotWidget = ShareHabitPreview(
        habit: widget.habit,
      );

      final imageFile = await screenshotController.captureFromWidget(
        screenshotWidget,
        context: contextFromWidget,
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/habit.png').create();
      await file.writeAsBytes(imageFile);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my habit progress!',
      );
    } catch (e) {
      debugPrint('Error sharing habit: $e');
    }

    setState(() {
      isShareLoading = false;
    });
  }

  Future<void> _shareHabitAsText() async {
    final completedDays = widget.habit.completionDates?.length ?? 0;
    final shareText = '''
🎯 Habit: ${widget.habit.habitName}
✅ Completed: $completedDays times
📝 Note: ${widget.habit.habitDescription ?? 'No note'}
    ''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final habitWidget = ShareHabitPreview(
      habit: widget.habit,
    );
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        title: "Share Habit",
      ),
      child: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SafeArea(
                bottom: false,
                child: habitWidget,
              ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton.tinted(
                          color: Colors.indigoAccent.shade100,
                          focusColor: Colors.indigoAccent.shade100,
                          onPressed: isShareLoading
                              ? null
                              : () {
                                  _shareHabitAsImage(habitWidget, context);
                                },
                          sizeStyle: CupertinoButtonSize.small,
                          child: isShareLoading
                              ? CircularProgressIndicator.adaptive()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.solidFileImage,
                                      color: Colors.indigoAccent.shade100,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Share Image',
                                      style: TextStyle(
                                        color: Colors.indigoAccent.shade100,
                                      ),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.solidFileLines),
                              SizedBox(width: 5),
                              Text('Share Text'),
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
    if (_scrollController.hasClients && mounted) {
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
              Color(widget.habit.colorCode).withOpacity(.8),
              Color(widget.habit.colorCode).withOpacity(.9),
              Color(widget.habit.colorCode).withOpacity(1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.habit.habitName,
                                      style: context.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.habit.habitDescription != null) ...[
                                      Text(
                                        widget.habit.habitDescription!,
                                        style: context.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildHabitGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Assets.app.appLogoDark.image(
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "HabitRise",
                        style: context.bodySmall?.copyWith(
                          color: Color(widget.habit.colorCode).colorRegardingToBrightness,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitGrid() {
    final List<DateTime> last90Days = [];
    DateTime today = DateTime.now();
    for (int i = 90; i >= 0; i--) {
      last90Days.add(today.subtract(Duration(days: i)));
    }

    final completionDates = widget.habit.completionDates?..sort();
    DateTime? startDate;
    DateTime? endDate;

    if (completionDates != null && completionDates.length > 1) {
      startDate = completionDates.first;
      endDate = completionDates.last;
    }

    return FittedBox(
      child: SizedBox(
        height: 152,
        child: GridView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: last90Days.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final dateTimeIn90Days = last90Days[index];
            final isToday = dateTimeIn90Days.isToday;

            bool isCompletedDate = completionDates?.any((d) => d.isSameDayWith(dateTimeIn90Days)) ?? false;

            bool isBetweenDates = false;
            if (startDate != null && endDate != null) {
              isBetweenDates = dateTimeIn90Days.isAfter(startDate) && dateTimeIn90Days.isBefore(endDate);
            }

            return Card(
              elevation: 0.1,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.white.withAlpha(50),
              color: isCompletedDate
                  ? Color(widget.habit.colorCode)
                  : isBetweenDates
                      ? Color(widget.habit.colorCode).withOpacity(.1)
                      : context.theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isToday ? context.primary : context.theme.dividerColor.withAlpha(50),
                  width: isToday ? 2.5 : .5,
                ),
              ),
              child: const SizedBox(
                height: 24,
                width: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
