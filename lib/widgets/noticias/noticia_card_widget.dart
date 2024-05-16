import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mi_utem/models/noticia.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/widgets/loading/loading_indicator.dart';
import 'package:mi_utem/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticiaCardWidget extends StatefulWidget {

  final Noticia noticia;

  const NoticiaCardWidget({
    required this.noticia,
  });

  @override
  State<NoticiaCardWidget> createState() => _NoticiaCardWidgetState();
}

class _NoticiaCardWidgetState extends State<NoticiaCardWidget> {

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 200,
    width: 200,
    child: Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTapNoticia,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: widget.noticia.imagen,
                placeholder: (ctx, url) => LoadingIndicator(),
                errorWidget: (ctx, url, error) => Icon(Icons.error, size: 110, color: Theme.of(context).colorScheme.error),
                height: 110,
                fit: BoxFit.cover,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    Text(widget.noticia.titulo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Spacer(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );

  _onTapNoticia() async {
    final url = widget.noticia.link;
    if (await canLaunchUrl(Uri.parse(url))) {
      AnalyticsService.logEvent("noticia_card_tap");
      await launchUrl(Uri.parse(url));
    } else {
      showErrorSnackbar(context, "No se pudo abrir la noticia. Intenta más tarde.");
    }
  }
}
