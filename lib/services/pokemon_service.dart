import 'package:dio/dio.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/models/pokemon_detail.dart';

class PokemonService {
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Pokemon>> fetchPokemons({int offset = 0, int limit = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/pokemon',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final results = res.data!['results'] as List;

    final details = await Future.wait(
      results.map((r) => _dio.get<Map<String, dynamic>>(r['url'] as String)),
    );
    return details
        .map((d) => Pokemon.fromDetailJson(d.data!))
        .toList();
  }

  Future<PokemonDetail> fetchDetail(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/pokemon/$id');
    return PokemonDetail.fromJson(res.data!);
  }

  Future<PokemonDetail?> searchByName(String name) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/pokemon/${name.toLowerCase().trim()}',
      );
      return PokemonDetail.fromJson(res.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
