// import 'package:m_sales/models/global_user.dart';
// import 'package:rxdart/rxdart.dart';

// GlobalUserState globalUserState = GlobalUserState();

// class GlobalUserState {
//   final BehaviorSubject _controller = BehaviorSubject.seeded(GlobalUser());

//   Stream get stream => _controller.stream;

//   GlobalUser get value => _controller.value;

//   update(GlobalUser data) {
//     _controller.add(data);
//   }

//   void dispose() {
//     _controller.close();
//   }

//   Map<String, dynamic> toJson() => {
//         "userId": globalUserState.value.userId,
//         "title": globalUserState.value.title,
//         "firstName": globalUserState.value.firstName,
//         "lastName": globalUserState.value.lastName,
//         "userType": globalUserState.value.userType,
//         "userName": globalUserState.value.userName,
//       };

//   toMap() {
//     return '''
// UER ID : ${globalUserState.value.userId} \n,
// TITLE : ${globalUserState.value.title} \n, 
// F_NAME : ${globalUserState.value.firstName} \n,
// L_NAME : ${globalUserState.value.lastName}\n,
// USER TYPE : ${globalUserState.value.userType}\n, 
// USER_NAME : ${globalUserState.value.userName}\n, 
// ''';
//   }
// }
