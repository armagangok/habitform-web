// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart';

// import '/core/core.dart';
// import '../../../../models/models.dart';
// import '../../../create_habit/create_habit_page.dart';
// import '../../../create_habit/provider/create_habit_provider.dart';
// import '../../provider/home_provider.dart';
// import 'habit_widget.dart';

// class HabitBuilder extends ConsumerWidget {
//   final List<Habit> habits;
//   final bool isLoading;

//   const HabitBuilder({
//     super.key,
//     required this.habits,
//     required this.isLoading,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     if (isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CupertinoActivityIndicator(),
//             SizedBox(height: 10),
//             Text(
//               LocaleKeys.common_loading_habits.tr(),
//               style: context.bodyMedium.copyWith(
//                 color: context.hintColor,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (habits.isEmpty) {
//       // No habits at all
//       return _noDataWidget(ref);
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15.0),
//       child: SafeArea(
//         top: false,
//         bottom: false,
//         child: _buildHabitList(habits),
//       ),
//     );
//   }

//   Widget _buildHabitList(List<Habit> habits) {
//     return Builder(
//       builder: (context) {
//         if (context.isTablet) {
//           // Tablet: 3 cards horizontally
//           return SingleChildScrollView(
//             physics: ClampingScrollPhysics(),
//             child: Wrap(
//               spacing: 20,
//               runSpacing: 20,
//               alignment: WrapAlignment.center,
//               children: habits.map((habit) {
//                 return SizedBox(
//                   width: (context.dynamicWidth - 100) / 3, // 3 cards per row
//                   child: HabitWidget(habit: habit),
//                 );
//               }).toList(),
//             ),
//           );
//         } else if (context.isLandscape) {
//           // Landscape phone: 2 cards horizontally
//           return SingleChildScrollView(
//             physics: ClampingScrollPhysics(),
//             child: Wrap(
//               spacing: 24,
//               runSpacing: 24,
//               alignment: WrapAlignment.center,
//               children: habits.map((habit) {
//                 return SizedBox(
//                   width: (context.dynamicWidth - 185) / 2,
//                   child: HabitWidget(habit: habit),
//                 );
//               }).toList(),
//             ),
//           );
//         }

//         // Mobile portrait: 2x2 grid
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: ClampingScrollPhysics(),
//           padding: EdgeInsets.zero,
//           itemCount: habits.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: 1,
//           ),
//           itemBuilder: (context, index) {
//             final habit = habits[index];
//             return HabitWidget(habit: habit);
//           },
//         );
//       },
//     );
//   }

//   Widget _noDataWidget(WidgetRef ref) => Builder(
//         builder: (context) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 20),
//               Lottie.asset(
//                 Assets.animations.astronout,
//                 fit: BoxFit.cover,
//               ),
//               SizedBox(height: 30),
//               Text(
//                 LocaleKeys.habit_no_habit_found.tr(),
//                 style: context.titleLarge.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 15),
//               CupertinoButton.tinted(
//                 sizeStyle: CupertinoButtonSize.medium,
//                 child: Text(
//                   LocaleKeys.habit_create_habit.tr(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onPressed: () async {
//                   final homeState = ref.read(homeProvider).value;
//                   if (homeState != null) {
//                     final canCreate = await ref.watch(createHabitProvider.notifier).canCreateHabit(homeState.habits.length);
//                     if (canCreate) {
//                       if (!context.mounted) return;
//                       showCupertinoSheet(
//                         enableDrag: false,
//                         context: context,
//                         builder: (contextFromSheet) {
//                           return CreateHabitPage();
//                         },
//                       );
//                     } else {
//                       if (!context.mounted) return;

//                       navigator.navigateTo(
//                         path: KRoute.prePaywall,
//                         data: {'isFromOnboarding': false},
//                       );
//                     }
//                   }
//                 },
//               ),
//             ],
//           );
//         },
//       );
// }
