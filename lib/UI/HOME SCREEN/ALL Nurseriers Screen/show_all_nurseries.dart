import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../../LOGIC/Home/home_cubit.dart';
import '../../../LOGIC/Home/home_state.dart';
import '../../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_PARENT.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../../../WIDGETS/SeeAllNurseriesCard/AllNurseriesCArd.dart';


class ShowAllNurseries extends StatefulWidget {
  const ShowAllNurseries({super.key});

  @override
  State<ShowAllNurseries> createState() => _ShowAllNurseriesState();
}

class _ShowAllNurseriesState extends State<ShowAllNurseries> {
  final TextEditingController _searchController = TextEditingController();
  List<NurseryProfile> _filteredNurseries = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredNurseries = state.nurseries
            .where((nursery) => nursery.name.toLowerCase().startsWith(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      FocusScope.of(context).unfocus();
    },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "All Nurseries",
            style: GoogleFonts.inter(
              fontSize: 25,
              foreground: Paint()
                ..shader = AppGradients.Projectgradient.createShader(
                  Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottombarParentScreen()),
                      (route) => false,
                );
              },
              child: const Icon(Icons.arrow_back, size: 30),
            ),
          ),
          leadingWidth: 35,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Search Field',
              onPressed: () {
                _searchController.clear();
                FocusScope.of(context).unfocus(); // hide keyboard
                setState(() {});
              },
            ),
          ],
        ),

        body: GestureDetector(onTap: (){
          FocusScope.of(context).unfocus();
        },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search nursery by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is NurseryHomeError) {
                      return Center(child: Text(state.message));
                    } else if (state is HomeLoaded) {
                      final query = _searchController.text.toLowerCase();

                      // Filter based on current input
                      final nurseriesToShow = query.isEmpty
                          ? state.nurseries
                          : state.nurseries
                          .where((nursery) => nursery.name.toLowerCase().startsWith(query))
                          .toList();

                      if (nurseriesToShow.isEmpty) {
                        return const Center(child: Text('No nurseries found.'));
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // Call the Cubit's method to reload nurseries
                          await context.read<HomeCubit>().refreshData();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(), // Ensure pull-to-refresh works
                          padding: const EdgeInsets.all(16),
                          itemCount: nurseriesToShow.length,
                          itemBuilder: (context, index) =>
                              TopRatedCard(nursery: nurseriesToShow[index]),
                        ),
                      );
                    }

                    return const Center(child: Text('No results found'));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
