import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '/core/core.dart';
import '../../../models/models.dart';

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
  final screenshotController = ScreenshotController();

  Future<void> _shareHabitAsImage() async {
    try {
      final imageFile = await screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            theme: context.theme,
            debugShowCheckedModeBanner: false,
            home: Material(
              child: ShareHabitPreview(habit: widget.habit),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
        context: context,
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
                child: ShareHabitPreview(habit: widget.habit),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton.tinted(
                          color: Colors.indigoAccent.shade100,
                          focusColor: Colors.indigoAccent.shade100,
                          onPressed: _shareHabitAsImage,
                          sizeStyle: CupertinoButtonSize.medium,
                          child: Row(
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
                          sizeStyle: CupertinoButtonSize.medium,
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

class ShareHabitPreview extends StatelessWidget {
  final Habit habit;

  const ShareHabitPreview({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(habit.colorCode).withOpacity(.8),
            Color(habit.colorCode).withOpacity(.9),
            Color(habit.colorCode).withOpacity(1),
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.habitName,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (habit.habitDescription != null) ...[
                                  Text(
                                    habit.habitDescription!,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 150,
                        child: _buildHabitGrid(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Assets.app.appLogoDark.image(
                      height: 30,
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "HabitRise",
                    style: context.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
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

    final completionDates = habit.completionDates?..sort();
    DateTime? startDate;
    DateTime? endDate;

    if (completionDates != null && completionDates.length > 1) {
      startDate = completionDates.first;
      endDate = completionDates.last;
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: last90Days.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
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
              ? Color(habit.colorCode)
              : isBetweenDates
                  ? Color(habit.colorCode).withOpacity(.1)
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
    );
  }
}
