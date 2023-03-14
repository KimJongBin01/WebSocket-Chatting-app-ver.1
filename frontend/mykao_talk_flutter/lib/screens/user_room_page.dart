import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/model/member_model.dart';
import 'package:mykao_talk_flutter/model/room_model.dart';

// 자 여기서 시작이야
class UserRoomsPage extends StatefulWidget {
  final ChattingAppUser user;

  const UserRoomsPage({
    super.key,
    required this.user,
  });

  @override
  State<UserRoomsPage> createState() => _UserRoomsState();
}

class _UserRoomsState extends State<UserRoomsPage> {
  late Future<List<RoomModel>> roomLst;
  final TextEditingController roomIdController = TextEditingController();
  late Timer _timer;
  var listRoom = [];

  @override
  void initState() {
    super.initState();
    roomLst = APIService.getUserRoomsById(widget.user.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Choose the room'),
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
      floatingActionButton: FloatingActionButton(
        heroTag: "createNewRoom",
        onPressed: () {
          // 새로 생성할 방의 id를 팝업창에서 입력하도록 띄움
          showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: const Text('Create New Room'),
                  content: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: roomIdController,
                            decoration:
                                const InputDecoration(hintText: 'New Room ID'),
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              await APIService.makeNewUserRooms(
                                roomid: roomIdController.text,
                                userid: widget.user.userId,
                                username: widget.user.username,
                              );
                              setState(() {
                                roomIdController.clear();
                                roomLst = APIService.getUserRoomsById(
                                  widget.user.userId,
                                );
                              });
                              _timer =
                                  Timer(const Duration(milliseconds: 500), () {
                                Navigator.pop(context);
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                            ))
                      ],
                    ),
                  ),
                )),
          );
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: roomLst,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            for (var roomModel in snapshot.data!)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 300,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    color: Colors.amber.withOpacity(0.8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 150,
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 60,
                                            ),
                                            Text(
                                              'Room: ${roomModel.roomId}',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 80,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.black87),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FloatingActionButton(
                                              heroTag:
                                                  "goToRoom${roomModel.roomId}",
                                              elevation: 1,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChattingPage(
                                                      user: widget.user,
                                                      roomId: roomModel.roomId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text('Enter'),
                                            ),
                                            FloatingActionButton(
                                              heroTag:
                                                  "DeleteRoom${roomModel.roomId}",
                                              elevation: 1,
                                              onPressed: () async {
                                                await APIService
                                                    .deleteUserRoomsById(
                                                  roomid: roomModel.roomId,
                                                  userid: widget.user.userId,
                                                  username:
                                                      widget.user.username,
                                                );
                                                setState(() {
                                                  roomLst = APIService
                                                      .getUserRoomsById(
                                                          widget.user.userId);
                                                });

                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.clear();
                                              },
                                              backgroundColor:
                                                  Colors.red.withOpacity(0.9),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        );
                      } else {
                        return Column(
                          children: const [
                            SizedBox(
                              height: 260,
                            ),
                            Text(
                              'No Chatting Rooms',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'You can add your Rooms',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return const Text('No Chatting Rooms');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
