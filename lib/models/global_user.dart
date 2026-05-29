import 'package:m_sales/utils/enums.dart';

class GlobalUser {
  late String userId = "";
  late String title = "";
  late String firstName = '';
  late String lastName = '';
  late String userName = '';
  late String emailAddress = '';
  late UserType userType = UserType.GUEST;
  late int currentTabId = 0;
}
