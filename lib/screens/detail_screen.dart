import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_app/models/pokemon_detail.dart';
import 'package:pokemon_app/models/pokemon_stat.dart';
import 'package:pokemon_app/services/favorites_service.dart';
import 'package:pokemon_app/services/pokemon_service.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/widgets/error_view.dart';
import 'package:pokemon_app/widgets/type_chip.dart';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;
  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _service = PokemonService();
  final _favService = FavoritesService();
  late Future<PokemonDetail> _detailFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchDetail(widget.pokemon.id);
    _favService.getIds().then((ids) {
      if (mounted) setState(() => _isFavorite = ids.contains(widget.pokemon.id));
    });
  }

  void _retry() => setState(() => _detailFuture = _service.fetchDetail(widget.pokemon.id));

  Future<void> _toggleFavorite(PokemonDetail detail) async {
    await _favService.toggleDetail(detail);
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetail>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final color = TypeChip.colorForType(widget.pokemon.type);
          final size = MediaQuery.of(context).size;
          final ovalWidth = size.width * 0.4;
          final ovalHeight = size.height * 0.3;
          final imageSize = size.width * 0.55;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: imageSize,
                        height: ovalHeight,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Container(
                                width: ovalWidth,
                                height: ovalHeight,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(ovalWidth / 2),
                                ),
                              ),
                            ),
                            Hero(
                              tag: widget.pokemon.heroTag,
                              child: Image.network(
                                widget.pokemon.gifUrl ?? widget.pokemon.imageUrl,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.35),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(error: snapshot.error, onRetry: _retry),
          );
        }
        return _DetailView(
          detail: snapshot.data!,
          isFavorite: _isFavorite,
          heroTag: widget.pokemon.heroTag,
          onFavoriteTap: () => _toggleFavorite(snapshot.data!),
        );
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final PokemonDetail detail;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final String heroTag;

  const _DetailView({
    required this.detail,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.heroTag,
  });

  static const _visibleStats = {'hp', 'attack', 'speed'};

  @override
  Widget build(BuildContext context) {
    final color = TypeChip.colorForType(detail.primaryType);
    final size = MediaQuery.of(context).size;
    final ovalWidth = size.width * 0.4;
    final ovalHeight = size.height * 0.3;
    final imageSize = size.width * 0.55;
    final name = detail.name[0].toUpperCase() + detail.name.substring(1);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: imageSize,
                      height: ovalHeight,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Center(
                            child: Container(
                              width: ovalWidth,
                              height: ovalHeight,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(ovalWidth / 2),
                              ),
                            ),
                          ),
                          Hero(
                            tag: heroTag,
                            child: Image.network(
                              detail.gifUrl ?? detail.imageUrl,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.catching_pokemon, size: 120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(maxHeight: size.height * 0.35),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '#${detail.id.toString().padLeft(3, '0')}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      TypeChip(type: detail.primaryType),
                      const SizedBox(height: 24),

                      Text(
                        'Estadísticas',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: detail.stats
                            .where((s) => _visibleStats.contains(s.name))
                            .map((s) => Expanded(child: _StatBlock(stat: s, color: color)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.85)),
                onPressed: () => context.pop(),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.85)),
                onPressed: onFavoriteTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final PokemonStat stat;
  final Color color;

  const _StatBlock({required this.stat, required this.color});

  static const _statLabels = {'hp': 'Fuerza', 'attack': 'Ataque', 'speed': 'Velocidad'};

  @override
  Widget build(BuildContext context) {
    final label = _statLabels[stat.name] ?? stat.name;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${stat.value}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
