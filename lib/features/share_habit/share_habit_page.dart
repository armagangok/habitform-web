import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '/core/core.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/habit/habit_model.dart';
import '../purchase/page/paywall_page.dart';
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
  final GlobalKey _imageShareButtonKey = GlobalKey();
  final GlobalKey _textShareButtonKey = GlobalKey();

  Rect _shareOriginFor(GlobalKey key) {
    try {
      final ctx = key.currentContext;
      if (ctx != null) {
        final renderObject = ctx.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          final topLeft = renderObject.localToGlobal(Offset.zero);
          final size = renderObject.size;
          if (size.width > 0 && size.height > 0) {
            return topLeft & size;
          }
        }
      }
    } catch (_) {}

    // Fallback to a tiny rect in the center of the screen (non-zero)
    final screenSize = MediaQuery.of(context).size;
    return Rect.fromLTWH(screenSize.width / 2, screenSize.height / 2, 1, 1);
  }

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
        sharePositionOrigin: _shareOriginFor(_imageShareButtonKey),
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

    await Share.share(
      shareText,
      sharePositionOrigin: _shareOriginFor(_textShareButtonKey),
    );
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
                            key: _imageShareButtonKey,
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
                            key: _textShareButtonKey,
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
    final isPro = ref.watch(purchaseProvider).value?.isSubscriptionActive ?? false;

    final isDark = context.cupertinoTheme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicWidth(
        child: CupertinoSegmentedControl<int>(
          groupValue: selected,
          selectedColor: isDark ? CupertinoColors.lightBackgroundGray.withValues(alpha: .4) : CupertinoColors.darkBackgroundGray.withValues(alpha: .5),
          unselectedColor: isDark ? CupertinoColors.darkBackgroundGray.withValues(alpha: .2) : CupertinoColors.darkBackgroundGray.withValues(alpha: .2),
          borderColor: context.primaryContrastingColor.withValues(alpha: .7),
          pressedColor: CupertinoColors.systemFill.withValues(alpha: 0.6),
          children: {
            for (int i = 0; i < provider.templates.length; i++)
              i: Builder(
                builder: (context) {
                  final bool isSelected = selected == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.templates[i].title,
                          overflow: TextOverflow.visible,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? CupertinoColors.white
                                : isDark
                                    ? CupertinoColors.white.withValues(alpha: .7)
                                    : CupertinoColors.black.withValues(alpha: .7),
                            fontSize: 14,
                          ),
                        ),
                        if (provider.templates[i].requiresPro && !isPro) ...[
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.lock_fill, size: 12, color: CupertinoColors.systemGrey),
                        ],
                      ],
                    ),
                  );
                },
              ),
          },
          onValueChanged: (i) {
            final template = provider.templates[i];
            if (template.requiresPro && !isPro) {
              showCupertinoSheet(
                context: context,
                builder: (context) => PaywallPage(isFromOnboarding: false),
              );

              return;
            }
            ref.read(shareTemplateProvider.notifier).select(i);
          },
        ),
      ),
    );
  }
}
