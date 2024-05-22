import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mi_utem/services/remote_config/remote_config.dart';
import 'package:mi_utem/widgets/image/default_network_image.dart';

import 'acerca_club_redes.dart';

class AcercaClub extends StatelessWidget {

  const AcercaClub({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: DefaultNetworkImage(url: RemoteConfigService.clubLogo),
          ),
          const SizedBox(height: 20),
          Text(
            RemoteConfigService.clubNombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          MarkdownBody(
            selectable: false,
            styleSheet: MarkdownStyleSheet(
              textAlign: WrapAlignment.center,
              p: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            data: RemoteConfigService.clubDescripcion,
          ),
          const SizedBox(height: 20),
          const AcercaClubRedes(),
        ],
      ),
    ),
  );
}