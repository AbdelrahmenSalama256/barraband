class User {
  bool? success;
  String? message;
  Info? info;

  User({this.success, this.message, this.info});

  User.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (info != null) {
      data['info'] = info!.toJson();
    }
    return data;
  }
}

class Info {
  int? id;
  String? name;
  String? email;
  int? status;
  String? photo;
  String? phone;
  String? country;
  String? emailVerified;
  String? affilateCode;
  String? createdAt;
  String? updatedAt;

  Info({
    this.id,
    this.name,
    this.email,
    this.status,
    this.photo,
    this.phone,
    this.country,
    this.emailVerified,
    this.affilateCode,
    this.createdAt,
    this.updatedAt,
  });

  Info.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    status = json['status'];
    photo = json['photo'];
    phone = json['phone'];
    country = json['country'];
    emailVerified = json['email_verified'];
    affilateCode = json['affilate_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['status'] = status;
    data['photo'] = photo;
    data['phone'] = phone;
    data['country'] = country;
    data['email_verified'] = emailVerified;
    data['affilate_code'] = affilateCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
