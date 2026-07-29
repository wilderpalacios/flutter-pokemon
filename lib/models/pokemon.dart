class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String? gifUrl;
  final String type;
  final String heroTag;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.gifUrl,
    required this.type,
    String? heroTag,
  }) : heroTag = heroTag ?? 'pokemon-$id';

  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final segments = Uri.parse(json['url'] as String).pathSegments;
    final id = int.parse(segments[segments.length - 2]);
    final name = json['name'] as String;
    return Pokemon(
      id: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      type: '',
    );
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final types = json['types'] as List;
    final type = types.isNotEmpty ? types.first['type']['name'] as String : '';
    final showdown = json['sprites']['other']['showdown'] as Map<String, dynamic>?;
    return Pokemon(
      id: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      gifUrl: showdown?['front_default'] as String?,
      type: type,
    );
  }
}
