import 'package:flutter/material.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/widgets/type_chip.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = TypeChip.colorForType(pokemon.type);
    final hasType = pokemon.type.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: hasType
                    ? color.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                width: double.infinity,
                height: 130,
                child: Hero(
                  tag: pokemon.heroTag,
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) =>
                        const Icon(Icons.catching_pokemon, size: 60),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pokemon.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (hasType) TypeChip(type: pokemon.type),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
