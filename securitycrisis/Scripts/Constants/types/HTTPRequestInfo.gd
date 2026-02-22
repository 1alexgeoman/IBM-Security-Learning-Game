extends Resource

class_name HTTPRequestInfo

signal completed(res)

var url: String
var headers: PackedStringArray 
var method: int
var data: String

var attempts: int
var parser: Callable

func _init(_url: String, _headers: PackedStringArray, _method: int, _data: String, _parser: Callable):
	url     = _url
	headers = _headers
	method  = _method
	data    = _data

	parser= _parser

	attempts= 0

func _to_string() -> String:
	return (
"HTTP Request info
  url: %s
  data: %s
  completed: %s
" % [url, data, completed.get_connections()])
