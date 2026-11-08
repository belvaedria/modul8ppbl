import 'package:flutter/material.dart';
import 'primary_button.dart';

class CartSummaryBar extends StatelessWidget {
  final int totalItem;
  final int totalHarga;
  final VoidCallback onKosongkan;
  final VoidCallback onCheckout;
  const CartSummaryBar({
    super.key,
    required this.totalItem,
    required this.totalHarga,
    required this.onKosongkan,
    required this.onCheckout,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalItem item • Rp$totalHarga',
            style: theme.textTheme.titleMedium,
          ),
          Row(
            children: [
              PrimaryButton(
                label: 'Kosongkan',
                icon: Icons.delete_outline,
                onPressed: onKosongkan,
              ),
              const SizedBox(width: 8),
              PrimaryButton(
                label: 'Checkout',
                icon: Icons.check_circle_outline,
                onPressed: onCheckout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
