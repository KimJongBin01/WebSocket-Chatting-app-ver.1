// we are going to add url for web and mobile
import 'package:socket_io_client/socket_io_client.dart' as IO;

String urlWebSocket = "http://localhost:5000/chat";
String urlWebSocketMobile = "http://10.0.2.2:5000/chat";
IO.Socket? socket;
