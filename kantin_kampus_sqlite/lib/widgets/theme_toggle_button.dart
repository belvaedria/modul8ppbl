import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});
  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    final gelap = mode == ThemeMode.dark;
    return IconButton(
      icon: Icon(gelap ? Icons.light_mode : Icons.dark_mode),
      tooltip: gelap ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
      onPressed: () => context.read<ThemeCubit>().toggle(),
    );
  }
}
