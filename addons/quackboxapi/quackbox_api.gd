extends Node


var _api_url = "http://localhost:6174/api/v1"
var _leaderboard_endpoint := "/leaderboard"
var _save_api_endpoint := "/save-data"

# HTTP headers to be sent with API requests
var _headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])

## Handles asynchronous HTTP requests to the REST API. [br]
## [param endpoint] the endpoint to call (e.g., "/leaderboard") [br]
## [param method] HTTPClient.Method (GET or POST) [br]
## [param data] Dictionary containing parameters or body data
## Returns an the text body, or null if the request was invalid
func _async_http_handler(endpoint, method: HTTPClient.Method, data: Dictionary):
	var request = HTTPRequest.new()
	add_child(request)
	var response_signal = request.request_completed
	if (method == HTTPClient.METHOD_GET):
		print(_dict_to_params(data))
		request.request(_api_url + endpoint + _dict_to_params(data), _headers, method, "")
	else:
		request.request(_api_url + endpoint, _headers, method, JSON.stringify(data))
	var response_params = await response_signal
	
	var result: int = response_params[0]
	var response_code: int = response_params[1]
	var headers: PackedStringArray = response_params[2]
	var body: String = response_params[3].get_string_from_utf8()
	
	#print(str("result: ", result))
	#print(str("response_code: ", response_code))
	#print(str("headers: ", headers))
	if not body.is_empty():
		print(str("body: ", body))
	
	if result == HTTPRequest.RESULT_SUCCESS:
		return body
	elif result == HTTPRequest.RESULT_CANT_CONNECT:
		push_warning("Could not connect to game dev api. Did not complete request.")
	elif result == HTTPRequest.RESULT_CONNECTION_ERROR:
		push_warning("Was unable to write the given data.")
	else:
		push_error(str("Unknown error. HTTPRequest Error Code: ", result))
	return null

## Parses a JSON array string into a typed array of objects
func _parse_arrays(json: String, type) -> Array:
	var parsed := JSON.parse_string(json)
	var entries = []
	
	if typeof(parsed) == TYPE_ARRAY:
		for entry in parsed:
			if (is_instance_of(type, LeaderboardEntry)):
				entries.append(LeaderboardEntry.from_json(entry))
			elif (is_instance_of(type, SaveDataEntry)):
				entries.append(SaveDataEntry.from_json(entry))
			elif (type == TYPE_STRING):
				entries.append(str(entry))
	return entries

## Converts a dictionary to a URL query parameter string
func _dict_to_params(request: Dictionary) -> String:
	var query_params_string: String = ""
	var param_count = 0
	for key: String in request.keys():
		if param_count == 0:
			query_params_string += str("?", key, "=", str(request.get(key)).uri_encode())
		else:
			query_params_string += str("&", key, "=", str(request.get(key)).uri_encode())
		param_count += 1
	return query_params_string

## Fetches leaderboard entries scoped to a specific user [br]
## [param value_name] the value to rank by [br]
## [param count] number of entries to retrieve (1-100) [br]
## [param player_slot] which user/player is submitting the score [br]
## Returns an [Array] of [LeaderboardEntry]
func get_user_leaderboard_entries(value_name: String, count: int, player_slot: int) -> Array[LeaderboardEntry]:
	if count > 100 or count < 1: 
		push_warning("Count must be between 1 and 100 inclusive")
		return []
	
	var request: Dictionary = {
		"scope": "user",
		"count": count,
		"value_name": value_name,
		"ascending": false,
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_leaderboard_endpoint, HTTPClient.METHOD_GET, request)
	if response == null:
		return []
	
	return _parse_arrays(response, LeaderboardEntry)

## Fetches global leaderboard entries [br]
## [param value_name] the value to rank by [br]
## [param count] number of entries to retrieve (1-100) [br]
## Returns an [Array] of [LeaderboardEntry]
func get_global_leaderboard_entries(value_name: String, count: int) -> Array[LeaderboardEntry]:
	if count > 100 or count < 1: 
		push_warning("Count must be between 1 and 100 inclusive")
		return []
	
	var request = {
		"scope": "global",
		"count": count,
		"value_name": value_name,
		"ascending": false
	}
	var response = await _async_http_handler(_leaderboard_endpoint, HTTPClient.METHOD_GET, request)
	if response == null:
		return []
	
	return _parse_arrays(response, LeaderboardEntry)

## Submits a new leaderboard entry [br]
## [param value_name] name of the metric being tracked [br]
## [param value_num] the score or value to submit [br]
## [param player_slot] which user/player to get/set data
func add_leaderboard_entry(value_name: String, value_num: float, player_slot: int) -> void:
	# TODO: Add error returns
	var request = {
		"value_name": value_name,
		"value_num": value_num,
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_leaderboard_endpoint, HTTPClient.METHOD_POST, request)
	return;

## Gets a list of save file names associated with a player slot [br]
## [param player_slot] which user/player to get/set data [br]
## Returns an [Array] of [String]
func get_save_file_names(player_slot: int) -> Array[String]:	
	var request = {
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_save_api_endpoint, HTTPClient.METHOD_GET, request)
	if response == null:
		return []
	
	return _parse_arrays(response, TYPE_STRING)

## Retrieves save data entries based on a regex pattern match [br]
## [param regex] a valid RegEx pattern to filter file names [br]
## [param player_slot] the player whose save files to search [br]
## Returns an [Array] of [SaveDataEntry]
func get_save_data(regex: RegEx, player_slot: int) -> Array[SaveDataEntry]:
	if not regex.is_valid():
		push_warning("Regex invalid")
	
	var request = {
		"regex": regex.get_pattern(),
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_save_api_endpoint, HTTPClient.METHOD_GET, request)
	if response == null:
		return []
	
	return _parse_arrays(response, SaveDataEntry)

## Retrieves a specific save data file [br]
## [param file_name] the name/path of the file to retrieve [br]
## [param player_slot] which user/player to get/set data [br]
## Returns a single [SaveDataEntry]
func get_save_data_file(file_name: String, player_slot: int) -> SaveDataEntry:
	var request = {
		"file_name": file_name,
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_save_api_endpoint, HTTPClient.METHOD_GET, request)
	if response == null:
		return null
	
	return SaveDataEntry.from_json(response)

## Uploads a new save data file [br]
## [param file_name] the name to give the saved file [br]
## [param data] the file content as a string [br]
## [param player_slot] which user/player to get/set data
func add_save_data(file_name: String, data: String, player_slot: int) -> void:
	# TODO: Add error returns
	var request = {
		"file_name": file_name,
		"data": data,
		"player_slot": player_slot
	}
	var response = await _async_http_handler(_save_api_endpoint, HTTPClient.METHOD_POST, request)
	return
