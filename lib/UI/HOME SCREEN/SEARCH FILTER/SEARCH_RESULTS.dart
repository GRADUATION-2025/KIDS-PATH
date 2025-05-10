import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../DATA MODELS/search filter/filter.dart';
import '../../../LOGIC/Home/home_cubit.dart';
import '../../../LOGIC/Home/home_state.dart';
import '../../../WIDGETS/nurserycard.dart';

class FilterResultsScreen extends StatelessWidget {
  final FilterParams filters;

  const FilterResultsScreen({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadFilteredNurseries(filters),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filter Results'),
        ),
        body: _buildResultsBody(),
      ),
    );
  }

  Widget _buildResultsBody() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) return const Center(child: CircularProgressIndicator());
        if (state is NurseryHomeError) return Center(child: Text(state.message));
        if (state is HomeLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.nurseries.length,
            itemBuilder: (context, index) => NurseryCard(nursery: state.nurseries[index]),
          );
        }
        return const Center(child: Text('No results found'));
      },
    );
  }
}