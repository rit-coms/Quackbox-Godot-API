extends RefCounted
class_name LeaderboardEntry

## The unique name describing the score
var value_name: String;
## The "score" value for the leaderboard
var value: float;
## The timestamp given by [method Time.get_datetime_dict_from_datetime_string] [br]
## Timestamp dictionaries are used
var time_stamp: Dictionary;

static func from_json(json: Dictionary) -> LeaderboardEntry:
	if json.has_all(["file_name", "data", "timestamp"]):
		var new_entry = LeaderboardEntry.new()
		new_entry.file_name = json["value_name"]
		new_entry.data = float(json["value"])
		new_entry.timestamp = Time.get_datetime_dict_from_datetime_string(json["timestamp"], false)
		return new_entry
	return null
