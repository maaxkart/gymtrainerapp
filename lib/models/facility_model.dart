class FacilityModel {

  final int id;
  final String name;

  FacilityModel({
    required this.id,
    required this.name,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {

    return FacilityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}