import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokemon_app/models/pokemon_detail.dart';
import 'package:pokemon_app/models/pokemon_stat.dart';

class FavoritesService {
  static const _key = 'favorites';

  Future<List<PokemonDetail>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => _fromJson(jsonDecode(e))).toList();
  }

  Future<Set<int>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => jsonDecode(e)['id'] as int).toSet();
  }

  Future<void> toggleDetail(PokemonDetail detail) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final ids = raw.map((e) => jsonDecode(e)['id'] as int).toSet();

    if (ids.contains(detail.id)) {
      raw.removeWhere((e) => jsonDecode(e)['id'] == detail.id);
    } else {
      raw.add(jsonEncode(_toJson(detail)));
    }
    await prefs.setStringList(_key, raw);
  }

  Map<String, dynamic> _toJson(PokemonDetail detail) => {
        'id': detail.id,
        'name': detail.name,
        'imageUrl': detail.imageUrl,
        'types': detail.types,
        'stats': detail.stats.map((stat) => {'name': stat.name, 'value': stat.value}).toList(),
      };

  PokemonDetail _fromJson(Map<String, dynamic> pokemon) => PokemonDetail(
        id: pokemon['id'] as int,
        name: pokemon['name'] as String,
        imageUrl: pokemon['imageUrl'] as String,
        types: pokemon['types'] != null
            ? List<String>.from(pokemon['types'] as List)
            : (pokemon['type'] != null ? [pokemon['type'] as String] : []),
        stats: pokemon['stats'] != null
            ? (pokemon['stats'] as List)
                .map((stat) => PokemonStat(name: stat['name'] as String, value: stat['value'] as int))
                .toList()
            : [],
      );
}
