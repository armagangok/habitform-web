import '/core/core.dart';
import '../habits/bloc/chain_habit/chain_habit_bloc.dart';
import '../habits/widgets/chained_habit_item.dart';
import 'widgets/grid_habit_widget.dart';

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
                          BlocBuilder<ChainHabitBloc, ChainHabitState>(
                            builder: (context, state) {
                              if (state is ChainHabitsFetched) {
                                return CupertinoListSection(
                                  header: Text("CHAINED HABITS"),
                                  dividerMargin: 0,
                                  additionalDividerMargin: 0,
                                  separatorColor: Colors.transparent,
                                  backgroundColor: context.cupertinoTheme.scaffoldBackgroundColor,
                                  children: [
                                    SizedBox(
                                      height: context.height(.18),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GridView.builder(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          scrollDirection: Axis.horizontal,
                                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
                                          itemCount: state.habits.length,
                                          itemBuilder: (context, index) {
                                            final chainedHabit = state.habits[index];
                                            return CustomButton(
                                              onTap: () {
                                                CupertinoScaffold.showCupertinoModalBottomSheet(
                                                  context: context,
                                                  builder: (contextFromSheer) {
                                                    return CupertinoPageScaffold(
                                                      navigationBar: SheetHeader(title: "Chained Habit"),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          children: [
                                                            ChainedHabitItem(chainedHabit: chainedHabit),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
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
                                                        chainedHabit.chainName,
                                                        style: context.bodySmall,
                                                      ),
                                                      ChainedHabitGrid(
                                                        chainedHabit: chainedHabit,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              if (state is ChainHabitInitial) {
                                return SizedBox.shrink();
                              }

                              if (state is ChainHabitsLoading) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (state is ChainHabitsFetchError) {
                                return Text(state.message);
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                          // BlocBuilder<ChainHabitBloc, ChainHabitState>(
                          //   builder: (context, state) {
                          //     return CupertinoListSection(
                          //       dividerMargin: 0,
                          //       additionalDividerMargin: 0,
                          //       separatorColor: Colors.transparent,
                          //       backgroundColor: Colors.transparent,
                          //       header: Text("SINGLE HABITS"),
                          //       children: [
                          //         CupertinoListTile(
                          //           leading: null,
                          //           title: Text("Habit"),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // ),
                          // BlocBuilder<ChainHabitBloc, ChainHabitState>(
                          //   builder: (context, state) {
                          //     return CupertinoListSection(
                          //       dividerMargin: 0,
                          //       additionalDividerMargin: 0,
                          //       separatorColor: Colors.transparent,
                          //       backgroundColor: Colors.transparent,
                          //       header: Text("QUIT HABITS"),
                          //       children: [
                          //         CupertinoListTile(
                          //           title: Text("data"),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // ),
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
