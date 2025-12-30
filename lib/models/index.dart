class KlaviyoProfile {
  final String? email;
  final String? phoneNumber;
  final String? externalId;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final String? title;
  final String? image;
  final KlaviyoLocation? location;
  final Map<String, dynamic>? properties;

  KlaviyoProfile({
    this.email,
    this.phoneNumber,
    this.externalId,
    this.firstName,
    this.lastName,
    this.organization,
    this.title,
    this.image,
    this.location,
    this.properties,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (externalId != null) map['externalId'] = externalId;
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (organization != null) map['organization'] = organization;
    if (title != null) map['title'] = title;
    if (image != null) map['image'] = image;
    if (location != null) map['location'] = location!.toMap();
    if (properties != null) map['properties'] = properties;
    return map;
  }
}

class KlaviyoLocation {
  final String? address1;
  final String? address2;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? region;
  final String? zip;
  final String? timezone;

  KlaviyoLocation({
    this.address1,
    this.address2,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.region,
    this.zip,
    this.timezone,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (address1 != null) map['address1'] = address1;
    if (address2 != null) map['address2'] = address2;
    if (city != null) map['city'] = city;
    if (country != null) map['country'] = country;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (region != null) map['region'] = region;
    if (zip != null) map['zip'] = zip;
    if (timezone != null) map['timezone'] = timezone;
    return map;
  }
}

class KlaviyoEvent {
  final String name;
  final Map<String, dynamic>? properties;
  final double? value;
  final String? uniqueId;

  KlaviyoEvent({
    required this.name,
    this.properties,
    this.value,
    this.uniqueId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'name': name};
    if (properties != null) map['properties'] = properties;
    if (value != null) map['value'] = value;
    if (uniqueId != null) map['uniqueId'] = uniqueId;
    return map;
  }
}

/// Exception thrown by Klaviyo SDK
class KlaviyoException implements Exception {
  final String message;

  KlaviyoException(this.message);

  @override
  String toString() => 'KlaviyoException: $message';
}
