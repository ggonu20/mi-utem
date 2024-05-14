class Noticia {
  int? id;
  String? titulo, subtitulo, link, imagen;

  Noticia({this.id, this.titulo, this.subtitulo, this.link, this.imagen});

  Noticia.empty() : this(
    id: null,
    titulo: '',
    subtitulo: '',
    link: '',
    imagen: '',
  );

  factory Noticia.fromJson(Map<String, dynamic>? json) => json != null ? Noticia(
    id: json["id"],
    titulo: json['yoast_head_json']['title'],
    subtitulo: json['yoast_head_json']['og_description'],
    imagen: json['yoast_head_json']['og_image'][0]['url'],
    link: "https://noticias.utem.cl/?p=${json['id']}",
  ) : Noticia.empty();

  static List<Noticia> fromJsonList(List<dynamic> json) => json.map((e) => Noticia.fromJson(e)).toList();
}
