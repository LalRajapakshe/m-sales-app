class ClosedTrip {
  int? id;
  String? ginStuHdrFgnRefCode;
  String? userId;

  ClosedTrip({this.id, this.ginStuHdrFgnRefCode, this.userId});

  ClosedTrip.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ginStuHdrFgnRefCode = json['ginStuHdrFgnRefCode'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ginStuHdrFgnRefCode'] = ginStuHdrFgnRefCode;
    data['userId'] = userId;

    return data;
  }

  factory ClosedTrip.empty() => ClosedTrip(ginStuHdrFgnRefCode: '', userId: '');
}
