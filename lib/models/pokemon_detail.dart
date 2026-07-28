import 'pokemon_stat.dart';

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<PokemonStat> stats;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] as String? ?? '',
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  String get primaryType => types.isNotEmpty ? types.first : '';
}
