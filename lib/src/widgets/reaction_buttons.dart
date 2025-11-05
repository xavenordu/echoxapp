import 'package:flutter/material.dart';

class ReactionButtons extends StatelessWidget {
  final void Function(bool isHelpful) onReaction;
  final bool? existingReaction;
  final bool compact;

  const ReactionButtons({
    super.key,
    required this.onReaction,
    this.existingReaction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Text(
            'Was this helpful?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 8),
        ],
        _ReactionButton(
          emoji: '👍',
          isSelected: existingReaction == true,
          onTap: () => onReaction(true),
        ),
        const SizedBox(width: 8),
        _ReactionButton(
          emoji: '👎',
          isSelected: existingReaction == false,
          onTap: () => onReaction(false),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.teal.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? Colors.teal.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}