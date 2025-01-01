import 'package:habitrise/core/extension/null_check_extension.dart';
import 'package:habitrise/features/habits/bloc/single_habit/single_habit_bloc.dart';

import '/core/core.dart';
import '../habits/bloc/chain_habit/chain_habit_bloc.dart';
import 'widgets/single_habit_grid.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<ChainHabitBloc>().add(FetchChainedHabitEvent());
    context.read<SingleHabitBloc>().add(FetchSingleHabitEvent());
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffold(
      body: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Overview'),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: [
                          // BlocBuilder<ChainHabitBloc, ChainHabitState>(
                          //   builder: (context, state) {
                          //     if (state is ChainHabitsFetched) {
                          //       return CupertinoListSection(
                          //         header: Text("CHAINED HABITS"),
                          //         dividerMargin: 0,
                          //         additionalDividerMargin: 0,
                          //         separatorColor: Colors.transparent,
                          //         backgroundColor: context.cupertinoTheme.scaffoldBackgroundColor,
                          //         children: [
                          //           SizedBox(
                          //             height: context.height(.18),
                          //             child: GridView.builder(
                          //               padding: EdgeInsets.zero,
                          //               scrollDirection: Axis.horizontal,
                          //               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
                          //               itemCount: state.habits.length,
                          //               itemBuilder: (context, index) {
                          //                 final chainedHabit = state.habits[index];
                          //                 return CustomButton(
                          //                   onTap: () {
                          //                     CupertinoScaffold.showCupertinoModalBottomSheet(
                          //                       context: context,
                          //                       builder: (contextFromSheer) {
                          //                         return CupertinoPageScaffold(
                          //                           navigationBar: SheetHeader(title: "Chained Habit"),
                          //                           child: Padding(
                          //                             padding: const EdgeInsets.all(10.0),
                          //                             child: ListView(
                          //                               shrinkWrap: true,
                          //                               children: [
                          //                                 ChainedHabitItem(chainedHabit: chainedHabit),
                          //                               ],
                          //                             ),
                          //                           ),
                          //                         );
                          //                       },
                          //                     );
                          //                   },
                          //                   child: Card.filled(
                          //                     shape: RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.circular(15),
                          //                       side: BorderSide(
                          //                         color: CupertinoColors.opaqueSeparator,
                          //                       ),
                          //                     ),
                          //                     color: context.cupertinoTheme.scaffoldBackgroundColor.withAlpha(150),
                          //                     child: Padding(
                          //                       padding: const EdgeInsets.all(8.0),
                          //                       child: Column(
                          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                         crossAxisAlignment: CrossAxisAlignment.start,
                          //                         children: [
                          //                           Text(
                          //                             chainedHabit.chainName,
                          //                             style: context.bodySmall,
                          //                           ),
                          //                           ChainedHabitGrid(
                          //                             chainedHabit: chainedHabit,
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 );
                          //               },
                          //             ),
                          //           ),
                          //         ],
                          //       );
                          //     }

                          //     if (state is ChainHabitInitial) return SizedBox.shrink();

                          //     if (state is ChainHabitsLoading) return Center(child: CupertinoActivityIndicator());

                          //     if (state is ChainHabitsFetchError) {
                          //       return Text(state.message);
                          //     } else {
                          //       return SizedBox.shrink();
                          //     }
                          //   },
                          // ),
                          BlocBuilder<SingleHabitBloc, SingleHabitState>(
                            builder: (context, state) {
                              if (state is SingleHabitInitial) return SizedBox.shrink();

                              if (state is SingleHabitsFetched) {
                                return CupertinoListSection(
                                  dividerMargin: 0,
                                  additionalDividerMargin: 0,
                                  separatorColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  header: Text("SINGLE HABITS"),
                                  children: [
                                    SizedBox(
                                      height: context.height(.18),
                                      child: GridView.builder(
                                        scrollDirection: Axis.horizontal,
                                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
                                        itemCount: state.habits.length,
                                        itemBuilder: (context, index) {
                                          final singleHabit = state.habits[index];

                                          print(singleHabit.toString());

                                          return CustomButton(
                                            onTap: () {
                                              context.cupertinoDialog(
                                                widget: BlocBuilder<SingleHabitBloc, SingleHabitState>(
                                                  builder: (context, state) {
                                                    return Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Row(
                                                                children: [
                                                                  Card(
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                                                    elevation: 0,
                                                                    color: context.primary,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Icon(
                                                                        FontAwesomeIcons.twitter,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        singleHabit.habitName,
                                                                        style: context.titleLarge.copyWith(fontWeight: FontWeight.w500),
                                                                      ),
                                                                      if (singleHabit.habitDescription.isNotNullAndNotEmpty)
                                                                        Text(
                                                                          singleHabit.habitDescription!,
                                                                          style: context.bodyMedium,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                            Column(
                                                              children: [
                                                                SingleHabitGrid(habit: singleHabit),
                                                              ],
                                                            ),
                                                            SizedBox(height: 10),
                                                            Row(
                                                              children: [
                                                                CupertinoButton.filled(
                                                                  sizeStyle: CupertinoButtonSize.large,
                                                                  padding: EdgeInsets.all(10),
                                                                  minSize: 0,
                                                                  onPressed: () {
                                                                    context.read<SingleHabitBloc>().add(UpdateHabitForTodayEvent(habit: singleHabit));
                                                                  },
                                                                  child: Icon(CupertinoIcons.check_mark),
                                                                ),
                                                                SizedBox(width: 10),
                                                                CupertinoButton.filled(
                                                                  sizeStyle: CupertinoButtonSize.large,
                                                                  padding: EdgeInsets.all(10),
                                                                  minSize: 0,
                                                                  onPressed: () {
                                                                    context.read<SingleHabitBloc>().add(DeleteSingleHabitEvent(habit: singleHabit));
                                                                    navigator.pop();
                                                                  },
                                                                  child: Icon(CupertinoIcons.trash),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                              // CupertinoScaffold.showCupertinoModalBottomSheet(
                                              //   context: context,
                                              //   builder: (contextFromSheer) {
                                              //     return Stack(
                                              //       children: [
                                              //         CupertinoPageScaffold(
                                              //           navigationBar: SheetHeader(title: singleHabit.habitName),
                                              //           child: Padding(
                                              //             padding: const EdgeInsets.all(10.0),
                                              //             child: ListView(
                                              //               shrinkWrap: true,
                                              //               children: [
                                              //                 Text("data1"),
                                              //                 Text("data2"),
                                              //                 Text("data3"),
                                              //                 SizedBox(height: 70),
                                              //               ],
                                              //             ),
                                              //           ),
                                              //         ),
                                              //         // Positioned.fill(
                                              //         //   child: Align(
                                              //         //     alignment: Alignment.bottomCenter,
                                              //         //     child: SafeArea(
                                              //         //       child: Padding(
                                              //         //         padding: EdgeInsets.symmetric(horizontal: 20),
                                              //         //         child: SizedBox(
                                              //         //           width: double.infinity,
                                              //         //           child: CupertinoButton.filled(
                                              //         //             onPressed: () {

                                              //         //             },
                                              //         //             child: Text("Delete"),
                                              //         //           ),
                                              //         //         ),
                                              //         //       ),
                                              //         //     ),
                                              //         //   ),
                                              //         // ),
                                              //       ],
                                              //     );
                                              //   },
                                              // );
                                            },
                                            child: Card.filled(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                side: BorderSide(
                                                  color: CupertinoColors.opaqueSeparator,
                                                ),
                                              ),
                                              color: context.cupertinoTheme.scaffoldBackgroundColor.withAlpha(150),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      singleHabit.habitName,
                                                      style: context.bodyMedium,
                                                    ),
                                                    if (singleHabit.habitDescription != null && singleHabit.habitDescription!.isNotEmpty)
                                                      Text(
                                                        singleHabit.habitDescription!,
                                                        style: context.bodyMedium,
                                                      ),
                                                    // ChainedHabitGrid(
                                                    //   chainedHabit: chainedHabit,
                                                    // ),
                                                    SingleHabitGrid(habit: singleHabit),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }

                              if (state is SingleHabitLoading) return Center(child: CupertinoActivityIndicator());

                              if (state is SingleHabitFetchError) {
                                return Text(state.message);
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
