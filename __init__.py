from flask import Flask, session, jsonify, request
from flask_socketio import SocketIO, join_room, leave_room, emit, send
from flaskext.mysql import MySQL
import datetime
 
 
app: Flask = Flask(__name__)
app.config['SECRET_KEY'] = 'secret'
app.config['SESSION_TYPE'] = 'filesystem'

################################# DB ################################# 
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = '4128'
app.config['MYSQL_DATABASE_DB'] = 'websocketchatting_project'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

conn = mysql.connect()
cursor = conn.cursor()

# 해당 방의 메시지를 모두 가져옴
def getChats(room):
    lst = []
    query = "Select userid, username, msg, ts from chats \
          where room='%s'" % room
    cursor.execute(query)
    msgLst = cursor.fetchall()

    for msg in msgLst:
        lst.append(
            {
            'userid' : msg[0],
            'username': msg[1],
            'msg': msg[2],
            'ts': str(msg[3]),
            }
            )
    return lst

# 해당 방에 메시지를 추가함
def addNewMsg(room, userid, username, msg):
    msg_forSQL = str(msg).replace("'", "''")

    print('문자 DB에 넣기 시작!!')
    date =  datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    try:
        query = "insert into chats(msg, room, username, ts, userid) \
              values('%s','%s','%s','%s', '%s');" % (msg_forSQL, room, username, str(date), userid)
        cursor.execute(query)
    
        conn.commit()
    except Exception as e:
        print("Exception >>> ",e)

# 새로운 사용자를 db에 등록
def registerNewUser(username, userid, userpw):
    try:
        query = "insert into user(username, userid, userpw) \
        values('%s', '%s', '%s');" %(username, userid, userpw)
        cursor.execute(query)
        conn.commit()
        
    except Exception as e:
        print(e)

################################# route & socket event #################################
# 회원가입 API
@app.route('/signup', methods=["POST"])
def signUp():
    redundancy = False
    form = request.get_json()
    username = form['username']
    userId = form['userId']
    userPw = form['userPw']

    # Id 중복 확인
    query = "Select userid from user where userid = '%s'" %userId
    cursor.execute(query)
    checker = cursor.fetchall()
    print(len(checker))

    if(len(checker) != 0):
        redundancy = True
    
    if(redundancy == False):
        registerNewUser(username, userId, userPw)
        print("Saving new user Success.")
    print("redundancy: ", redundancy)
    value = {'redundancy' : redundancy}
    return jsonify(value)

# 로그인 API
@app.route('/login', methods=['POST'])
def login():
    form = request.get_json()
    userId = form['userId']
    query = "Select username, userid, userpw from user where userid = '%s'" %userId
    cursor.execute(query)
    checker = cursor.fetchone()
    
    if len(checker) == 0:
        return None
    else:
        return jsonify({
      "username": checker[0],
      "userId": checker[1],
      "userPw": str(checker[2]),
    })

# 로그인한 사용자의 채팅방 목록 API
@app.route('/userChattingRooms', methods=['POSt'])
def listOfRooms():
    form = request.get_json()
    roomId = form['roomId']
    roomLst = []

    query = "Select room from usersroom where userid='%s'" % roomId
    cursor.execute(query)
    roomIdFromDB = cursor.fetchall()
    print("왜 안돌아 이거 ",roomIdFromDB)
    
    for room in roomIdFromDB:
        roomLst.append({'roomid': room[0]})
    return jsonify(roomLst)

# 로그인한 사용자의 채팅방 삭제 API
@app.route('/userChattingRooms/delete', methods=['POSt'])
def deleteRoom():
    form = request.get_json()
    roomId = form['roomId']
    userId = form['userId']
    username = form['username']
    addNewMsg(msg=username+'[ %s ] left the room'%userId, 
              userid="SYSTEM0000", username="System", room=roomId)
    query = "delete from usersroom where room='%s' and userid='%s'" % (roomId, userId)
    cursor.execute(query)
    conn.commit()
    emit('message', {'msg': getChats(roomId)}, room=roomId)
    return

# 로그인한 사용자의 채팅방 생성 API
@app.route('/userChattingRooms/create', methods=['POST'])
def createRoom():
    form = request.get_json()
    userId = form['userId']
    roomId = form['roomId']
    username = form['username']
    query = "Insert into usersroom (userid, room) values ('%s','%s')" % (userId, roomId)
    cursor.execute(query)
    conn.commit()
    addNewMsg(msg=username+'[ %s ] join the room'%userId, 
            userid="SYSTEM0000", username="System", room=roomId)
    return
    
###################################### 웹 소켓 ##########################################
socketio = SocketIO(app, cors_allowed_origins='*')

# join 이벤트 리스너
@socketio.on('join', namespace='/chat')
def join(data):
    print('join data =', data)
    username = data['username']
    room = data['roomId']
    userId = data['userId']
    join_room(room)
    # message 이벤트 emit
    emit('message', {'msg': getChats(room)}, room=room)

# text 이벤트 리스너
@socketio.on('text', namespace='/chat')
def text(message):
    print('text data =',message)
    username = message['username']
    room = message['room']
    userId = message['userid']
    addNewMsg(msg=message['msg'], username=username, room=room, userid=userId)
    # message 이벤트 emit
    emit('message', {'msg': getChats(room)}, room=room)

# left 이벤트 리스너 (단순히 방을 나갔을 때)
@socketio.on('left', namespace='/chat')
def left(message):
    room = message['room']
    leave_room(room)
    print("방을 나갔습니다.")

    lst = getChats(room)
    if len(lst) == 0:
         # message 이벤트 emit
        emit('message', {'msg': [{'msg': "No messages has been sent"}]})
    else:
         # message 이벤트 emit
        emit('message', {'msg': lst}, room=room)

# delete 이벤트 리스너 (해당 방을 삭제 했을 때)
@socketio.on('delete', namespace='/chat')
def delete(form):
    roomId = form['roomId']
    userId = form['userId']
    username = form['username']

    addNewMsg(msg=username+'[ %s ] left the room'%userId, 
              userid="SYSTEM0000", username="System", room=roomId)
    
    query = "delete from usersroom where room='%s' and userid='%s'" % (roomId, userId)
    cursor.execute(query)
    conn.commit()  
    leave_room(roomId)

    # message 이벤트 emit
    emit('message', {'msg': getChats(roomId)}, room=roomId)

if __name__ == '__main__':
    # Run Flask-SocketIO App
    socketio.run(app, debug=True)