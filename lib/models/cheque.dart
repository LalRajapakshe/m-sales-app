class Cheque {
  int? id;
  String? bankNo;
  double? chequeAmount;
  String? chequeNo;
  String? branchNo;
  String? date;
  String? accountNo;
  String? userId;
  String? recieptId;

  Cheque(
      {this.id,
      this.bankNo,
      this.chequeAmount,
      this.chequeNo,
      this.branchNo,
      this.date,
      this.accountNo,
      this.userId,
      this.recieptId});

  Cheque.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bankNo = json['bankNo'];
    chequeAmount = json['chequeAmount'];
    chequeNo = json['chequeNo'];
    branchNo = json['branchNo'];
    date = json['date'];
    accountNo = json['accountNo'];
    userId = json['userId'];
    recieptId = json['recieptId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bankNo'] = bankNo;
    data['chequeAmount'] = chequeAmount;
    data['chequeNo'] = chequeNo;
    data['branchNo'] = branchNo;
    data['date'] = date;
    data['accountNo'] = accountNo;
    data['userId'] = userId;
    data['recieptId'] = recieptId;
    return data;
  }

  factory Cheque.empty() => Cheque(
      id: 0,
      bankNo: '',
      branchNo: '',
      date: '',
      userId: '',
      recieptId: '',
      chequeAmount: 0.00,
      accountNo: '',
      chequeNo: '');
}
