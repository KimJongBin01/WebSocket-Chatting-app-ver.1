import 'imports.dart';
import 'dart:async';

class StreamSocket {
  // 방출하는 데이터 타입이 dynamic
  final _socketResponse = StreamController<dynamic>();

  // sink는 StreamController의 스트림에 정보를 추가
  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  // Stream 타입으로 데이터 방출
  Stream<dynamic> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
