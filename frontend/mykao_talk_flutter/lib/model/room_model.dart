class RoomModel {
  final String roomId;

  RoomModel({
    required this.roomId,
  });

  RoomModel.fromJson(Map<dynamic, dynamic> json) : roomId = json['roomid'];
}
