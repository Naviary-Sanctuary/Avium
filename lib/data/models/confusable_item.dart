class ConfusableItem {
  const ConfusableItem({
    required this.nameKo,
    required this.nameEn,
    required this.noteKo,
  });

  final String nameKo;
  final String nameEn;
  final String noteKo;

  factory ConfusableItem.fromJson(Map<String, dynamic> json) {
    return ConfusableItem(
      nameKo: json['nameKo'] as String,
      nameEn: json['nameEn'] as String,
      noteKo: json['noteKo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nameKo': nameKo,
      'nameEn': nameEn,
      'noteKo': noteKo,
    };
  }
}
