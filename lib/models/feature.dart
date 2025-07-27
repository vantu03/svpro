class Feature {
  final String id;
  final String label;
  final String icon;

  Feature({required this.id, required this.label, required this.icon});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      label: json['label'],
      icon: json['icon'],
    );
  }
}
