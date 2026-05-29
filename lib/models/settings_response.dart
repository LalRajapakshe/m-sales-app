class SettingResponse {
  int? sysId;
  String? fromDate;
  String? toDate;
  String? settingType;
  String? settingValue;

  SettingResponse(
      {this.sysId,
      this.fromDate,
      this.toDate,
      this.settingType,
      this.settingValue});

  SettingResponse.fromJson(Map<String, dynamic> json) {
    sysId = json['sysId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    settingType = json['settingType'];
    settingValue = json['settingValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sysId'] = sysId;
    data['fromDate'] = fromDate;
    data['toDate'] = toDate;
    data['settingType'] = settingType;
    data['settingValue'] = settingValue;
    return data;
  }
}
