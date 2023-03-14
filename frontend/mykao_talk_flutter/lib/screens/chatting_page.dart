import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/model/member_model.dart';
import 'package:mykao_talk_flutter/screens/user_room_page.dart';
import 'package:mykao_talk_flutter/widgets/chatting_bubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChattingPage extends StatefulWidget {
  final ChattingAppUser user;
  final String roomId;
  const ChattingPage({
    super.key,
    required this.user,
    required this.roomId,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  // property
  final TextEditingController _sendController = TextEditingController();
  StreamSocket streamSocket = StreamSocket();
  bool isServerOnline = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    connectAndListen(widget.user.username, widget.roomId, widget.user.userId);
  }

  // 웹소켓 연결
  void connectAndListen(String username, String roomId, String userid) {
    var uri = urlWebSocketMobile;
    socket = IO.io(uri, OptionBuilder().setTransports(['websocket']).build());
    socket!.connect();
    socket!.onConnect((_) {
      print("Connect Success!!!!!!!!!!!!!!");

      socket!.emit(
        'join',
        {
          'username': username,
          'roomId': roomId,
          'userId': userid,
        },
      );
      socket!.on('message', (data) {
        setState(() {
          streamSocket.addResponse(data);
        });
      });
      socket!.onDisconnect((_) {
        setState(() {
          isServerOnline = false;
        });
      });
    });
  }

  void onTapGoToChattingRoomListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRoomsPage(
          user: widget.user,
        ),
      ),
    );
  }

  @override
  void dispose() {
    streamSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chatting room[${widget.roomId}]'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.amber.shade600,
        elevation: 5,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber.shade600),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 100,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.username,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        widget.user.userId,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.arrow_back_ios_new_sharp,
                  size: 30,
                ),
                title: const Text(
                  "Back To Choose Room",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  print("나가자!");

                  socket!.emit('left', {
                    'userid': widget.user.userId,
                    'username': widget.user.username,
                    'room': widget.roomId,
                  });
                  onTapGoToChattingRoomListPage();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_outline_outlined,
                  size: 30,
                ),
                title: const Text(
                  "Remove This room",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () async {
                  socket!.emit('delete', {
                    'userId': widget.user.userId,
                    'username': widget.user.username,
                    'roomId': widget.roomId,
                  });
                  _timer = Timer(const Duration(milliseconds: 500), () {
                    onTapGoToChattingRoomListPage();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_outlined,
                  size: 30,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  _timer = Timer(const Duration(milliseconds: 500), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  });
                },
              ),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: streamSocket.getResponse,
              builder: ((context, snapshot) {
                print('888888888888888888888888888888888888888');
                print('>>>>>>>>>${snapshot.data}');
                if (snapshot.hasData) {
                  dynamic doc = snapshot.data;

                  List msg = [];
                  List msg2 = [];
                  msg.addAll(doc['msg']);
                  for (int i = 0; i < msg.length; i++) {
                    msg2.insert(0, msg[i]);
                  }
                  print(snapshot.data);
                  return ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: msg.length,
                    itemBuilder: (context, index) {
                      var txt = msg2[index]['msg'].toString();
                      var ts = msg2[index]['ts'].toString();

                      if (msg2[index]['userid'] == 'SYSTEM0000') {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 300,
                                height: 25,
                                alignment: Alignment.center,
                                color: Colors.grey.shade400,
                                child: Text(
                                  msg2[index]['msg']
                                      .toString()
                                      .replaceAll("'", ""),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        );
                      } else {
                        return ChattingBuble(
                          username: msg2[index]['username'].toString(),
                          msg: msg2[index]['msg'].toString(),
                          ts: ts,
                          currentUSer: (msg2[index]['userid'].toString() ==
                              widget.user.userId),
                        );
                      }
                    },
                  );
                } else {
                  return Text(widget.user.username);
                }
              }),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: 'Send Message',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                  ),
                  child: IconButton(
                      onPressed: () {
                        socket!.emit('text', {
                          'msg': _sendController.text,
                          'room': widget.roomId,
                          'username': widget.user.username,
                          'userid': widget.user.userId,
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
