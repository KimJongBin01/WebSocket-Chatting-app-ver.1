import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/screens/sign_up_page.dart';
import 'package:mykao_talk_flutter/screens/user_room_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? userId; // ID로 회원 조회
  String? userPw; // 조회한 회원의 pw와 비교
  String? roomId;
  String? warningMSG;
  // form 형식, post로 서버에 데이터 전송
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userPwController = TextEditingController();
  final TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: const Text(
                  'MyKao Talk',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            SizedBox(
              child: Form(
                key: _formKey,
                child: Container(
                  alignment: Alignment.center,
                  // ID, PW, rommID 입력 폼을 나열하기 위해 column사용
                  child: Column(
                    children: [
                      // ID 입력란
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: userIdController,
                              decoration:
                                  const InputDecoration(hintText: 'Enter Id'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // PW 입력란
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: userPwController,
                              decoration: const InputDecoration(
                                  hintText: 'Enter password.'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 60,
                      ),
                      // 회원가입, 채팅 목록 화면 이동 페이지
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 채팅방 입장
                          Container(
                            width: 100,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(17),
                              ),
                            ),
                            child: SizedBox(
                              width: 200,
                              child: FloatingActionButton(
                                heroTag: 'Chattings',
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.amber,
                                elevation: 0,

                                // pressed event
                                onPressed: () async {
                                  var resultMember =
                                      await APIService.getMemberById(
                                          userIdController.text);
                                  // 계정 확인
                                  if (resultMember.userPw ==
                                      userPwController.text) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString(
                                        'roomId', roomIdController.text);
                                    prefs.setString(
                                        'userId', userIdController.text);

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserRoomsPage(
                                            user: resultMember,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 25,
                            height: 20,
                          ),

                          // 회원가입 페이지 이동
                          Container(
                            width: 100,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(17),
                              ),
                            ),
                            child: SizedBox(
                              width: 200,
                              child: FloatingActionButton(
                                heroTag: 'SignUpButton',
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.amber,
                                elevation: 0,

                                // pressed event
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
