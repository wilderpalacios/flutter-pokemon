import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/models/pokemon_detail.dart';
import 'package:pokemon_app/services/favorites_service.dart';
import 'package:pokemon_app/services/pokemon_service.dart';
import 'package:pokemon_app/widgets/error_view.dart';
import 'package:pokemon_app/widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  final _favService = FavoritesService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<List<Pokemon>> _pokemonsFuture;
  List<Pokemon> _pokemons = [];
  bool _loadingMore = false;

  String _query = '';
  Set<int> _favoriteIds = {};

  PokemonDetail? _searchResult;
  bool _searching = false;
  bool _searchNotFound = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pokemonsFuture = _loadFirstPage();
    _loadFavorites();

    _searchController.addListener(() {
      final q = _searchController.text.trim();
      setState(() {
        _query = q.toLowerCase();
        if (q.isEmpty) {
          _searchResult = null;
          _searchNotFound = false;
          _searching = false;
        }
      });
      if (q.isNotEmpty) {
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 600),
          () => _searchPokemon(q),
        );
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_loadingMore) _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Pokemon>> _loadFirstPage() async {
    final pokemons = await _service.fetchPokemons();
    _pokemons = pokemons;
    return pokemons;
  }

  Future<void> _loadMore() async {
    if (!mounted) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _service.fetchPokemons(offset: _pokemons.length);
      if (mounted) setState(() => _pokemons = [..._pokemons, ...more]);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await _favService.getIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  Future<void> _toggleFavorite(PokemonDetail detail) async {
    await _favService.toggleDetail(detail);
    if (!mounted) return;
    setState(() {
      if (_favoriteIds.contains(detail.id)) {
        _favoriteIds.remove(detail.id);
      } else {
        _favoriteIds.add(detail.id);
      }
    });
  }

  Future<void> _searchPokemon(String name) async {
    if (!mounted) return;
    setState(() {
      _searching = true;
      _searchNotFound = false;
    });
    try {
      final result = await _service.searchByName(name);
      if (mounted) {
        setState(() {
          _searchResult = result;
          _searchNotFound = result == null;
        });
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _retry() => setState(() => _pokemonsFuture = _loadFirstPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error, onRetry: _retry);
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeader(),
              if (_query.isNotEmpty)
                _buildSearchResult()
              else ...[
                _buildGrid(_pokemons),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _loadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pokémones',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Busca un Pokémon...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_searching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_searchNotFound) {
      return const SliverFillRemaining(
        child: Center(child: Text('Pokémon no encontrado')),
      );
    }
    if (_searchResult != null) {
      final p = _searchResult!;
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: PokemonCard(
                  pokemon: Pokemon(
                    id: p.id,
                    name: p.name,
                    imageUrl: p.imageUrl,
                    type: p.primaryType,
                  ),
                  isFavorite: _favoriteIds.contains(p.id),
                  onTap: () => context.push('/pokemon/${p.id}', extra: Pokemon(
                    id: p.id,
                    name: p.name,
                    imageUrl: p.imageUrl,
                    type: p.primaryType,
                  )),
                  onFavoriteTap: () => _toggleFavorite(p),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return const SliverFillRemaining(child: SizedBox.shrink());
  }

  Widget _buildGrid(List<Pokemon> pokemons) {
    final left = <Pokemon>[];
    final right = <Pokemon>[];
    for (var i = 0; i < pokemons.length; i++) {
      if (i.isEven) {
        left.add(pokemons[i]);
      } else {
        right.add(pokemons[i]);
      }
    }

    Widget cardFor(Pokemon p) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PokemonCard(
            pokemon: p,
            isFavorite: _favoriteIds.contains(p.id),
            onTap: () async {
              await context.push('/pokemon/${p.id}', extra: p);
              _loadFavorites();
            },
            onFavoriteTap: () async {
              final detail = await _service.fetchDetail(p.id);
              await _toggleFavorite(detail);
            },
          ),
        );

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(children: left.map(cardFor).toList()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(children: right.map(cardFor).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
