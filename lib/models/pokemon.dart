class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String type;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
  });

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
    return Pokemon(
      id: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      type: type,
    );
  }
}
