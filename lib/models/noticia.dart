class Noticia {
  int id;
  String titulo, subtitulo, link, imagen;

  Noticia({required this.id, required this.titulo, required this.subtitulo, required this.link, required this.imagen});

  factory Noticia.fromJson(Map<String, dynamic> json) => Noticia(
    id: json["id"],
    titulo: json['yoast_head_json']['title'],
    subtitulo: json['yoast_head_json']['og_description'],
    imagen: json['yoast_head_json']['og_image'][0]['url'],
    link: "https://noticias.utem.cl/?p=${json['id']}",
  );

  static List<Noticia> fromJsonList(List<dynamic> json) => json.map((e) => Noticia.fromJson(e)).toList();
}
