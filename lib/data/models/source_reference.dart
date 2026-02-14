class SourceReference {
  const SourceReference({
    required this.type,
    required this.title,
    required this.year,
    this.publisher,
    this.authors = const <String>[],
  });

  final String type;
  final String title;
  final int year;
  final String? publisher;
  final List<String> authors;

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    return SourceReference(
      type: json['type'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      publisher: json['publisher'] as String?,
      authors: (json['authors'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'title': title,
      'year': year,
      if (publisher != null) 'publisher': publisher,
      if (authors.isNotEmpty) 'authors': authors,
    };
  }
}
