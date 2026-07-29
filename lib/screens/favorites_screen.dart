import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/models/pokemon_detail.dart';
import 'package:pokemon_app/services/favorites_service.dart';
import 'package:pokemon_app/widgets/pokemon_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favService = FavoritesService();
  List<PokemonDetail> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favs = await _favService.getAll();
    if (mounted) setState(() => _favorites = favs);
  }

  Future<void> _remove(PokemonDetail detail) async {
    await _favService.toggleDetail(detail);
    _load();
  }

  Pokemon _toPokemon(PokemonDetail p) => Pokemon(
        id: p.id,
        name: p.name,
        imageUrl: p.imageUrl,
        gifUrl: null,
        type: p.primaryType,
        heroTag: 'fav-${p.id}',
      );

  @override
  Widget build(BuildContext context) {
    final left = <PokemonDetail>[];
    final right = <PokemonDetail>[];
    for (var i = 0; i < _favorites.length; i++) {
      if (i.isEven) { left.add(_favorites[i]); } else { right.add(_favorites[i]); }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Favoritos'),
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64),
                  SizedBox(height: 16),
                  Text('Aún no tienes favoritos'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: left.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PokemonCard(
                            pokemon: _toPokemon(p),
                            isFavorite: true,
                            onTap: () async {
                              await context.push('/pokemon/${p.id}', extra: _toPokemon(p));
                              _load();
                            },
                            onFavoriteTap: () => _remove(p),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: right.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PokemonCard(
                          pokemon: _toPokemon(p),
                          isFavorite: true,
                          onTap: () async {
                            await context.push('/pokemon/${p.id}', extra: _toPokemon(p));
                            _load();
                          },
                          onFavoriteTap: () => _remove(p),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
