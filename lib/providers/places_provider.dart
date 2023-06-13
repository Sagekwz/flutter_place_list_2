import 'dart:io';

import 'package:place_list_test/models/place_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  print('In _getDatabase method');
  print('dbPath: ' + dbPath);
  print('joined path: ' + path.join(dbPath, 'places.db'));

  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      print('create table');
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  print('db: ' + db.toString());
  return db;
}

class UserePlaceNotifier extends StateNotifier<List<Place>> {
  UserePlaceNotifier() : super([]);

  Future<void> loadPlaces() async {
    print('In loadPlaces metthod');
    final Database db = await _getDatabase();
    final data = await db.query('user_places');
    print(data);
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                latitude: row['lat'] as double,
                longitude: row['lng'] as double,
                address: row['address'] as String),
          ),
        )
        .toList();

    state = places;
  }

  // function add new place
  void addNewPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/${filename}');

    final newPlace =
        Place(title: title, image: copiedImage, location: location);
    state = [newPlace, ...state];

    final Database db = await _getDatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
  }

  void removePlace(Place placeItem) {
    state.remove(placeItem);
  }

  void insertPlace(int index, Place placeItem) {
    state.insert(index, placeItem);
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserePlaceNotifier, List<Place>>(
  (ref) => UserePlaceNotifier(),
);
