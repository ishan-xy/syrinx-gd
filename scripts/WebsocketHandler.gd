extends Node2D

var httpRequest := HTTPRequest.new()
var clients: PackedByteArray = []
var authBtn

func _ready() -> void:
	authBtn = get_tree().get_nodes_in_group("auth_button")[0]
	add_child(httpRequest)
	set_physics_process(false)

func _auth_error(error: String) -> void:
	authBtn.OnAuthResponse(false, error)
	print_debug("auth error: ", error)

func _lobby_error(error: String) -> void:
	authBtn.OnAuthResponse(false, error)
	print_debug("lobby error: ", error)

func _auth(Username:String, Password:String) -> void:
	httpRequest.request_completed.connect(_on_auth_response)
	#print("authenticating")
	var err := httpRequest.request("https://api-syrinx.ccstiet.com/authanticate", [], HTTPClient.METHOD_POST, JSON.stringify({"Username": Username, "Password":Password}))
	if err != OK: return _auth_error("_auth: Error while sending request / Connection error")

var SessionIDBodyString: String
var SessionID: PackedByteArray
signal auth_response(bool)
func _on_auth_response(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK or body == null: 
		authBtn.OnAuthResponse(false, result)
		return _auth_error("Http response error, result error: "+str(result))
	#if response_code != 200: _auth_error("Http response error, response code: "+str(response_code))
	SessionIDBodyString = body.get_string_from_ascii()
	var json: Dictionary = JSON.parse_string(body.get_string_from_ascii())
	if json == null: return _auth_error("Json parse error")
	elif json.has("error"): return _auth_error("Server error:\n" + str(json["error"]))
	elif !json.has("SessionID"): return _auth_error("Mendatory key SessionID not found")
	SessionID = json["SessionID"]
	
	httpRequest.request_completed.disconnect(_on_auth_response)
	httpRequest.request_completed.connect(_on_lobby_response)
	httpRequest.request("https://api-syrinx.ccstiet.com/getlobby", [], HTTPClient.METHOD_POST, SessionIDBodyString)

var LobbyID: String
var wsConn := WebSocketClient.new()
func _on_lobby_response(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_ascii())
	print(body.get_string_from_ascii())
	if json == null: return _lobby_error("Json parse error")
	elif json.has("Error"): return _lobby_error("Server error:\n" + str(json["Error"]))
	elif !json.has("LobbyID"): return _lobby_error("Mendatory key LobbyID not found")
	LobbyID = json["LobbyID"]
	#print(json)
	if json.has("Level"):
		if json["Level"] != 1:
			authBtn.OnAuthResponse(false, "You are not allowed to access this level")
		elif json["Level"] == 1:
			authBtn.OnAuthResponse(true, "")
	wsConn.connection_established.connect(_on_ws_ready)
	set_physics_process(true)
	#print("Connected to Lobby")
	#auth_response.emit(true)
	wsConn.connection_closed.connect(_connect_to_lobby)
	wsConn.connect_to_url("ws://api-syrinx.ccstiet.com/lobby/" + LobbyID)

func _connect_to_lobby(_was_clean: bool = false) -> void:
	set_physics_process(false)
	await get_tree().create_timer(.5).timeout
	set_physics_process(true)
	#print("_connect_to_lobby: called")
	wsConn.connect_to_url("ws://api-syrinx.ccstiet.com/lobby/" + LobbyID)

	#$"../Control".queue_free()

func _on_ws_ready(_peer: WebSocketPeer, _protocol: String) -> void:
	wsConn.send(SessionID)
	#print("Questions Websocket Connected")
	wsConn.data_received.connect(_on_data_recieved)

var myIndex: int = -1
signal data_recieved(String)
func _on_data_recieved(_peer : WebSocketPeer, message, _is_string : bool) -> void:
	if _is_string:
		data_recieved.emit(message.get_string_from_ascii())

func _physics_process(_delta) -> void:
	if wsConn != null:
		wsConn.poll()
