class LocationModel {
  final int id;
  final String title;
  final String address;
  final String latLong;
  final String description;
  final String phone;
  final String website;
  final int locationType;

  LocationModel(
      {this.id,
      this.title,
      this.address,
      this.latLong,
      this.description,
      this.phone,
      this.website,
      this.locationType});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
        id: json['id'],
        title: json['title'],
        address: json['address'],
        latLong: json['lat_long'],
        description: json['description'],
        phone: json['phone'],
        website: json['website'],
        locationType: json['location_type']);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'lat_long': latLong,
        'phone': phone,
        'website': website,
        'description': description,
        'location_type_id': locationType
      };
}
