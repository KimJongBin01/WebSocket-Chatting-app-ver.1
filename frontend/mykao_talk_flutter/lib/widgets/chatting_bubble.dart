import 'package:mykao_talk_flutter/imports.dart';

class ChattingBuble extends StatelessWidget {
  final String username;
  final String msg;
  final String ts;
  final bool currentUSer;

  const ChattingBuble({
    super.key,
    required this.username,
    required this.msg,
    required this.ts,
    required this.currentUSer,
  });
  @override
  Widget build(BuildContext context) {
    return currentUSer
        ?
        // 현재 사용자
        Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ts,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.amber.shade300,
                    child: const Icon(Icons.person),
                  ),
                ],
              ),
            ),
          )
        // 상대방 유저들
        : Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.amber.shade300,
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ts,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
