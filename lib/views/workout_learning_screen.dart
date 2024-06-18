import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view models/workoutsearch_viewmodel.dart';
import 'workoutplay_screen.dart';


class WorkOutLearningView extends StatefulWidget {
  @override
  _WorkOutLearningViewState createState() => _WorkOutLearningViewState();
}

class _WorkOutLearningViewState extends State<WorkOutLearningView> {
  late WorkOutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<WorkOutViewModel>(context, listen: false);
    _viewModel.loadWorkoutData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Consumer<WorkOutViewModel>(
        builder: (context, viewModel, child) {
          return viewModel.workoutData.isEmpty
              ? Center(child: CircularProgressIndicator())
              : DefaultTabController(
            length: viewModel.workoutData.length,
            child: Column(
              children: [
                Stack(
                  children: [
                    TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      tabs: viewModel.workoutData
                          .map((workout) => Tab(text: workout.bigWo))
                          .toList(),
                    ),
                    Container(
                      color: Colors.black87,
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: WorkOutSearchDelegate(viewModel),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: viewModel.workoutData
                        .map((workout) => ListView.builder(
                      itemCount: workout.smallWo.length,
                      itemBuilder: (context, index) {
                        String exercise = workout.smallWo[index];
                        return ListTile(
                          title: Text(
                            exercise,
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPlayerScreen(query: exercise),
                              ),
                            );
                          },
                        );
                      },
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WorkOutSearchDelegate extends SearchDelegate<String> {
  final WorkOutViewModel viewModel;

  WorkOutSearchDelegate(this.viewModel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> results = viewModel.searchResults(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            results[index],
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutPlayerScreen(query: results[index]),
              ),
            );
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black87),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(left: 20),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Consumer<WorkOutViewModel>(
        builder: (context, viewModel, child) {
          List<String> suggestions = viewModel.searchResults(query);
          return ListView(
            children: suggestions
                .map((wo) => ListTile(
              title: Text(
                wo,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutPlayerScreen(query: wo),
                  ),
                );
              },
            ))
                .toList(),
          );
        },
      ),
    );
  }
}
