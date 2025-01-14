// ignore_for_file: public_member_api_docs, sort_constructors_first
import '/core/core.dart';

// class SettingItemWidget extends StatelessWidget {
//   const SettingItemWidget({
//     super.key,
//     required this.title,
//     this.subtitle,
//     required this.onTap,
//     this.action,
//     this.leadingIcon,
//     this.itemSort = ItemSort.between,
//     this.subtitleColor,
//     this.subtitleOpacity,
//   });

//   final String title;
//   final String? subtitle;
//   final void Function() onTap;
//   final Widget? action;
//   final Widget? leadingIcon;
//   final ItemSort itemSort;

//   final Color? subtitleColor;
//   final double? subtitleOpacity;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CupertinoButton(
//           borderRadius: itemSort.borderRadius,
//           padding: EdgeInsets.zero,
//           onPressed: onTap,
//           child: Padding(
//             padding: EdgeInsets.all(8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 leadingIcon ?? SizedBox.shrink(),
//                 leadingIcon == null ? SizedBox.shrink() : SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         textAlign: TextAlign.left,
//                       ),
//                       subtitle != null
//                           ? Text(
//                               subtitle!,
//                               textAlign: TextAlign.left,
//                             )
//                           : const SizedBox.shrink(),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 action ?? CupertinoListTileChevron(),
//               ],
//             ),
//           ),
//         ),
//         Visibility(
//           visible: itemSort.isDividerVisible,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 48.0),
//             child: Divider(
//               color: context.theme.dividerColor.withValues(alpha: 0.25),
//               height: 0,
//               thickness: .75,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class SettingLeadingWidget extends StatelessWidget {
  const SettingLeadingWidget({
    super.key,
    required this.iconData,
    required this.cardColor,
    this.padding,
  });

  final IconData iconData;
  final Color cardColor;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: EdgeInsets.all(padding ?? 3),
        child: Icon(
          iconData,
          color: Colors.white.withValues(alpha: .9),
        ),
      ),
    );
  }
}

// enum ItemSort { firstItem, lastItem, between, single }

// extension EasySort on ItemSort {
//   BorderRadius get borderRadius {
//     switch (this) {
//       case ItemSort.firstItem:
//         return const BorderRadius.only(
//           topLeft: Radius.circular(12),
//           topRight: Radius.circular(12),
//         );

//       case ItemSort.lastItem:
//         return const BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         );

//       case ItemSort.single:
//         return const BorderRadius.all(Radius.circular(12));

//       default:
//         return BorderRadius.zero;
//     }
//   }

//   bool get isDividerVisible {
//     switch (this) {
//       case ItemSort.firstItem:
//         return true;
//       case ItemSort.lastItem:
//         return false;
//       case ItemSort.single:
//         return false;
//       case ItemSort.between:
//         return true;
//     }
//   }
// }
