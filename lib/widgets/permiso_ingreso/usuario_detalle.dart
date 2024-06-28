import 'package:flutter/material.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:mi_utem/widgets/profile_photo.dart';

class UsuarioDetalle extends StatelessWidget {
  final User user;

  const UsuarioDetalle({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          ProfilePhoto(
            fotoUrl: user.fotoUrl,
            iniciales: user.iniciales,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nombreCompletoCapitalizado,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text("${user.rut}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}