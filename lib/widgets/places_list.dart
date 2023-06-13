import 'package:place_list_test/models/place_model.dart';
import 'package:place_list_test/providers/places_provider.dart';
import 'package:place_list_test/screen/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({
    super.key,
    required this.places,
  });

  final List<Place> places;

  @override
  ConsumerState<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  @override
  Widget build(BuildContext context) {
    void removeItem(placeItem, index) {
      setState(() {
        ref.read(userPlacesProvider.notifier).removePlace(placeItem);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('Remove this Item'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    ref.read(userPlacesProvider.notifier).insertPlace(
                          index,
                          placeItem,
                        );
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Canceled remove item'),
                    ),
                  );
                },
                child: const Text('back'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.places.isEmpty) {
      return Center(
        child: Text(
          'No Place data',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.places.length,
      itemBuilder: (cxt, index) => Dismissible(
        onDismissed: (directoin) => removeItem(widget.places[index], index),
        key: ValueKey(widget.places[index]),
        child: ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: FileImage(widget.places[index].image),
          ),
          title: Text(widget.places[index].title,
              style: Theme.of(cxt).textTheme.titleMedium),
          subtitle: Text(
            widget.places[index].location.address,
            style: Theme.of(cxt).textTheme.titleSmall,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PlaceDetail(
                  placeData: widget.places[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
