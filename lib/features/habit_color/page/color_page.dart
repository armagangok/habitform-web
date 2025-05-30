import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

class ColorPage extends ConsumerWidget {
  const ColorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.colors_color.tr(),
        closeButtonPosition: CloseButtonPosition.left,
        trailing: TrailingActionButton(
          onPressed: () {},
          child: Text(LocaleKeys.common_done.tr()),
        ),
      ),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            color: context.primary,
          );
        },
      ),
    );
  }
}
