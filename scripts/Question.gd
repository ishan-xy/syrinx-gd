# Question.gd
extends Resource

class_name Question

const MAX_TIME = 10

var id: int
var text_timestamp: float

var text: String
var Points: int

var hint: String
var hint_timestamp: float
var hintPoints: int

var userAns: String
var isAnswered: bool

func _init(_id: int, _text: String = "", _isAnswered: bool = false):
	id = _id
	text = _text
	isAnswered = _isAnswered
	userAns = ""
	text_timestamp = Time.get_unix_time_from_system()
	hint_timestamp = text_timestamp
	hint = ""

func add_hint(_hint):
	hint = _hint
	hint_timestamp = Time.get_unix_time_from_system()

func add_text(_text):
	text = _text
	text_timestamp = Time.get_unix_time_from_system()

func validate_text() -> bool:
	return text != "" and Time.get_unix_time_from_system() - text_timestamp < MAX_TIME
	
func validate_hint() -> bool:
	return hint != "" and Time.get_unix_time_from_system() - hint_timestamp < MAX_TIME
