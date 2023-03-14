class ChattingAppUser {
  // 회원가입, 로그인에서 사용할 멤버 class
  final String username;
  final String userId;
  final String userPw;

  ChattingAppUser({
    required this.username,
    required this.userId,
    required this.userPw,
  });

  ChattingAppUser.fromJson(Map<dynamic, dynamic> json)
      : username = json["username"],
        userId = json["userId"],
        userPw = json["userPw"];
}
