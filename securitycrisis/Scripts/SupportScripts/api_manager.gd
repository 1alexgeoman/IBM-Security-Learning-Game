extends HTTPRequest

const API_BASE: String = "https://test.ibm.jamestbest.co.uk"

const API_QUESTION_GET = "/question/header/"
const API_QUESTION_MARK = "/question/mark/"
const API_QUESTIONS_GET= "/questions"

const API_ANSWER_GET: String = "/question/answer/"

const MAX_REQUEST_NODES: int= 3 # based on the rate limit per second (ish, it's 2 in reality)
const MAX_ATTEMPTS: int= 4 # i made this number up
const CODE_403_SLEEP_TIME: int= 1 # wait 1 second if we're rate limited
const CODE_OTHER_SLEEP_TIME: float= 0.5

# this stores both the url, data, and such, as well as the number of retries so far
var queued_requests: Array[HTTPRequestInfo]= []
var request_nodes: Array[HTTPRequest]= []

func _ready():
	for i in range(MAX_REQUEST_NODES):
		var req_node: HTTPRequest= HTTPRequest.new()

		add_child(req_node)
		request_nodes.append(req_node)

func send_request(info: HTTPRequestInfo) -> Signal:
	queued_requests.push_back(info)

	_try_next_request()

	return info.completed

func _try_next_request() -> void:
	var req_node: HTTPRequest= _get_free_req_node()
	if req_node:
		_next_node_request(req_node)
	else:
		printerr("There are no free request nodes. Request is queued")

func _get_free_req_node() -> HTTPRequest:
	for node in request_nodes:
		# should be that if the request node has disconnected it can take on a new request
		if node.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			return node

	return null

func _next_node_request(req_node: HTTPRequest):
	if queued_requests.is_empty():
		return

	var r: HTTPRequestInfo= queued_requests.pop_front()

	# the bind is adding two extra args to req complete, the req_node that completed the request
	#  as well as the starting number of attempts
	req_node.request_completed.connect(_on_request_completed.bind(req_node, r))

	var err: int= req_node.request(r.url, r.headers, r.method, r.data)

	if err != OK:
		# if we fail in general then just pass on the error handling to the request completed function
		#  it will inc attempts, re-add the request and get a new one
		_on_request_completed(HTTPRequest.RESULT_CANT_CONNECT, 0, [], PackedByteArray(), req_node, r)
	else:
		print("MADE REQUEST")

func _on_request_completed(result: int, code: int, headers: PackedStringArray, body: PackedByteArray, req_node: HTTPRequest, req: HTTPRequestInfo):
	# if the request failed, either in general or from a non-200 res code then retry the request
	# else start a new one
	# If the errcode is rate limit then wait some time
	if (result != RESULT_SUCCESS or code != HTTPClient.RESPONSE_OK) and req.attempts <= MAX_ATTEMPTS:
		# if we can try again then just add it back to the queue
		#  we could re-try straight away but I'd rather get the next from the queue
		req.attempts += 1
		queued_requests.push_back(req)

		print("The request on url %s has failed with result %d and code %d. Re-attempting after %d attempts" % [req.url, result, code, req.attempts])

		if code == HTTPClient.RESPONSE_TOO_MANY_REQUESTS:
			# sleep for x time, then once done get another request, I'm really liking this connect->bind stuff
			get_tree().create_timer(CODE_403_SLEEP_TIME).timeout.connect(_next_node_request.bind(req_node))
		else:
			get_tree().create_timer(CODE_OTHER_SLEEP_TIME).timeout.connect(_next_node_request.bind(req_node))

		return

	if result == RESULT_SUCCESS:
		# parse the results however needed and then return that new value
		req.completed.emit(req.parser.call(result, code, headers, body))
		return

func mark_question_parallel(question_id: int, user_answer: String) -> Signal:
	var req_body = JSON.stringify({
		"questionID": question_id,
		"answer": user_answer
	})

	var headers = ["Content-Type: application/json"]

	var info: HTTPRequestInfo= HTTPRequestInfo.new(
		API_BASE + API_QUESTION_MARK,
		headers,
		HTTPClient.METHOD_POST,
		req_body,
		mark_question_callback
	)

	return send_request(info)

# {
# 	success: bool
#   question: Question
# }
func mark_question(question_id: int, user_answer: String) -> Dictionary:
	return await mark_question_attempt(question_id, user_answer, 0)

func mark_question_attempt(question_id: int, user_answer: String, attempts: int) -> Dictionary:
	var req_body = JSON.stringify({
		"questionID": question_id,
		"answer": user_answer
	})

	var headers = ["Content-Type: application/json"]
	request(API_BASE + API_QUESTION_MARK, headers, HTTPClient.METHOD_POST, req_body)

	var res = await request_completed

	if res[0] != RESULT_SUCCESS or res[1] != HTTPClient.RESPONSE_OK:
		if attempts > MAX_ATTEMPTS:
			return {"success": false}
		else:
			print("marking question failed with result %d and code %d. Attempted %d times" % [res[0], res[1], attempts])
			await get_tree().create_timer(CODE_OTHER_SLEEP_TIME).timeout
			print("Marking question that was errored has finished waiting and is sending another request")
			return await mark_question_attempt(question_id, user_answer, attempts + 1)

	return mark_question_callback(res[0], res[1], res[2], res[3])
 
 
func mark_question_callback(_result, _code, _headers, body) -> Dictionary:
	var json_data = JSON.parse_string(body.get_string_from_utf8())
	var data = json_data.data

	var question: Question_Marked
	var type= QUESTION_TYPES.ENUM.get(data.type)

	if (type == QUESTION_TYPES.ENUM.MCQ):
		question= MCQ_Marked.new(type, data.mark, data.kp)
	elif (type == QUESTION_TYPES.ENUM.EssayQ):
		var samples: Array= JSON.parse_string(data.sample_answers)
		question= Essay_Marked.new(type, data.mark, data.kp, data.dist, samples, data.feedback)
	else: 
		printerr("Invalid type: %s" % data.type)
		return {"success": false}

	return {"success": true, "question": question}

func g_question(question_id: int) -> Signal:
	var info= HTTPRequestInfo.new(
		API_BASE + API_QUESTION_GET + "%d" % question_id,
		PackedStringArray(),
		HTTPClient.METHOD_GET,
		"",
		get_question_callback
	)
	
	return send_request(info)

func get_question(question_id: int) -> Question:
	request(API_BASE + API_QUESTION_GET + "%d" % question_id)

	var res = await request_completed
	return get_question_callback(res[0], res[1], res[2], res[3])

func get_question_callback(result, code, _headers, body) -> Question:
	if result != RESULT_SUCCESS:
		printerr("Unable to fetch question from API, recieved error %d with %d" % [result, code])
		return null

	if code != HTTPClient.RESPONSE_OK:
		printerr("Recieved non 200 code from API when fetching question, recieved error %d" % code)
		return null

	var json_data = JSON.parse_string(body.get_string_from_utf8())
	var q_data = json_data.data

	var q: Question = Question.new(q_data.id, q_data.question, q_data.text, QUESTION_TYPES.ENUM.get(q_data.type))

	return q

func get_answer(question_id: int):
	request(API_BASE + API_ANSWER_GET + "%d" % question_id)

	var res = await request_completed
	return get_answer_callback(res[0], res[1], res[2], res[3])

func get_answer_callback(result, code, _headers, body):
	if result != RESULT_SUCCESS:
		printerr("Unable to fetch answer from API, recieved error %d with %d" % [result, code])
		return null

	if code != HTTPClient.RESPONSE_OK:
		printerr("Recieved non 200 code from API when fetching answer, recieved error %d" % code)
		return null

	var json_data = JSON.parse_string(body.get_string_from_utf8())
	var answer_data = JSON.parse_string(json_data.correctAnswer)[0]

	return answer_data

func get_level_questions(level: int) -> Array[Question]:
	request(API_BASE + API_QUESTIONS_GET + "?level=%d" % level)

	var res= await request_completed
	return get_level_questions_callback(res[0], res[1], res[2], res[3])

func get_level_questions_callback(result, code, _headers, body) -> Array[Question]:
	if result != RESULT_SUCCESS:
		printerr("Unable to fetch questions from API, recieved error %d with %d" % [result, code])
		return []

	if code != HTTPClient.RESPONSE_OK:
		printerr("Recieved non 200 code from API when fetching questions, recieved error %d" % code)
		return []
	
	var json_data= JSON.parse_string(body.get_string_from_utf8())

	var qs: Array[Question]= []
	for q_data in json_data:
		var type: QUESTION_TYPES.ENUM= QUESTION_TYPES.ENUM.get(q_data.type)
		qs.append(Question.new(q_data.id, q_data.question, q_data.text, type))
	
	return qs
