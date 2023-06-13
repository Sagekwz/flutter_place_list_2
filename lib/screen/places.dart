import 'package:place_list_test/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:place_list_test/models/place_model.dart';
import 'package:place_list_test/providers/places_provider.dart';
import 'package:place_list_test/screen/add_new_place.dart';

class PlacecScreen extends ConsumerStatefulWidget {
  const PlacecScreen({
    super.key,
  });

  @override
  ConsumerState<PlacecScreen> createState() {
    return _PlaceScreenState();
  }
}

class _PlaceScreenState extends ConsumerState<PlacecScreen> {
  late Future<void> _placeFuture;

  @override
  void initState() {
    super.initState();
    print('In initState method');
    _placeFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    List<Place> userPlaces = ref.watch(userPlacesProvider);

    void onAddButton() async {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => const AddPlaceScreen(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            onPressed: onAddButton,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _placeFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : PlacesList(places: userPlaces),
        ),
      ),
    );
  }
}
