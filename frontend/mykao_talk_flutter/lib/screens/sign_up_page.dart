import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/model/member_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();

  bool warningMSG = false;
  bool createResult = false;
  late Timer _timer;

  final TextEditingController userNameController = TextEditingController();

  final TextEditingController userIdController = TextEditingController();

  final TextEditingController userPwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sign Up'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.amber.shade600,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _signUpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'MyKao Talk!',
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              warningMSG
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: createResult
                                ? Colors.green.shade100
                                : Colors.pink.shade100,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            'This ID is already exist!',
                            style: TextStyle(
                              color: createResult ? Colors.green : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    )
                  : const SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: userNameController,
                      decoration: const InputDecoration(hintText: 'User Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: userIdController,
                      decoration: const InputDecoration(hintText: 'User ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ID';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: userPwController,
                      decoration:
                          const InputDecoration(hintText: 'User Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 45,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.5,
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
                        backgroundColor: Colors.amber.shade400,
                        elevation: 0,

                        // pressed event
                        onPressed: () async {
                          if (_signUpFormKey.currentState!.validate()) {
                            _signUpFormKey.currentState!.save();

                            final newUser = ChattingAppUser(
                              username: userNameController.text,
                              userId: userIdController.text,
                              userPw: userPwController.text,
                            );

                            var redundancy =
                                await APIService.registUser(newUser);
                            if (redundancy) {
                              setState(() {
                                warningMSG = redundancy;
                              });
                            } else {
                              setState(() {
                                createResult = true;
                                userNameController.clear();
                                userIdController.clear();
                                userPwController.clear();
                              });
                              _timer =
                                  Timer(const Duration(milliseconds: 1000), () {
                                Navigator.pop(context);
                              });
                            }
                          }
                        },
                        child: const Text(
                          'Sign Up',
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
    );
  }
}
