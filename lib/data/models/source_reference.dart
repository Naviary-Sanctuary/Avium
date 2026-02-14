class SourceReference {
  const SourceReference({
    required this.type,
    required this.title,
    this.year,
    this.publisher,
    this.authors = const <String>[],
    this.url,
  });

  final String type;
  final String title;
  final int? year;
  final String? publisher;
  final List<String> authors;
  final String? url;

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    final dynamic yearRaw = json['year'];
    return SourceReference(
      type: json['type'] as String,
      title: json['title'] as String,
      year: yearRaw is int ? yearRaw : int.tryParse('$yearRaw'),
      publisher: json['publisher'] as String?,
      authors: (json['authors'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'title': title,
      if (year != null) 'year': year,
      if (publisher != null) 'publisher': publisher,
      if (authors.isNotEmpty) 'authors': authors,
      if (url != null) 'url': url,
    };
  }
}
