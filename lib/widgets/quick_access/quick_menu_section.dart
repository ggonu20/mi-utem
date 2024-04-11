import 'package:flutter/material.dart';
import 'package:mi_utem/services/remote_config/remote_config.dart';
import 'package:mi_utem/widgets/quick_access/quick_menu_card.dart';

class QuickMenuSection extends StatelessWidget {
  const QuickMenuSection({
    super.key
  });

  List<Map<String, dynamic>> get _quickMenu => RemoteConfigService.quickMenu;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text("Acceso rápido".toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 130,
        child: ListView.separated(
          itemCount: _quickMenu.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) => QuickMenuCard(card: _quickMenu[index]),
        ),
      ),
    ],
  );
}
