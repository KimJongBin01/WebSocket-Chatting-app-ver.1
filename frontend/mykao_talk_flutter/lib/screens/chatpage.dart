import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/model/member_model.dart';

class ChattingPage2 extends StatefulWidget {
  final ChattingAppUser user;
  final String roomId;
  const ChattingPage2({
    super.key,
    required this.user,
    required this.roomId,
  });

  @override
  State<ChattingPage2> createState() => _ChattingPage2State();
}

class _ChattingPage2State extends State<ChattingPage2> {
  // property
  final TextEditingController _sendController = TextEditingController();
  bool connect = false;
  String? sentMsg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chatting room[///]'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.amber.shade600,
        elevation: 5,
        automaticallyImplyLeading: true,
        leading: IconButton(
            onPressed: () async {
              socket!.emit('left', {
                'username': widget.user.username,
                'room': widget.roomId,
              });
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();

              if (mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp)),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 14,
            child: SingleChildScrollView(
              child: Container(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 312,
                  child: TextFormField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: 'Send Message',
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                  ),
                  child: IconButton(
                      onPressed: () {
                        socket!.emit('text', {
                          'msg': sentMsg,
                          'room': widget.roomId,
                          'username': widget.user.username
                        });
                        setState(() {
                          _sendController.clear();
                        });
                      },
                      icon: const Icon(Icons.send_outlined)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
