import '/core/core.dart';
import '../add_habit/add_habit_page.dart';
import '../habits/bloc/chain_habit/chain_habit_bloc.dart';
import '../habits/bloc/single_habit/single_habit_bloc.dart';
import 'widgets/single_habit/single_habit_builder.dart';

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
              leading: Align(
                widthFactor: 1,
                child: TrailingActionButton(
                  child: Icon(
                    CupertinoIcons.gear_solid,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
              largeTitle: Text('HabitRise'),
              trailing: Align(
                widthFactor: 1,
                child: Builder(builder: (context) {
                  return TrailingActionButton(
                    child: Icon(
                      CupertinoIcons.add_circled_solid,
                      size: 22,
                    ),
                    onPressed: () {
                      CupertinoScaffold.showCupertinoModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (contextFromSheet) {
                          return AddHabitPage();
                        },
                      );
                    },
                  );
                }),
              ),
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
                          //                                 // ChainedHabitItem(chainedHabit: chainedHabit),
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
                          //                           // ChainedHabitGrid(
                          //                           //   chainedHabit: chainedHabit,
                          //                           // ),
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
                          SingleHabitBuilder(),
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
