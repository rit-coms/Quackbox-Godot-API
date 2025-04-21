extends RefCounted
class_name SaveDataEntry

## The filename of the entry
var file_name: String;
## The data stored within the save entry (as a string)
var data: String;
## The timestamp given by [method Time.get_datetime_dict_from_datetime_string] [br]
## Timestamp dictionaries are used
var timestamp: Dictionary;

static func from_json(json: Dictionary) -> SaveDataEntry:
	if typeof(json) != TYPE_DICTIONARY:
		return null
	if json.has_all(["file_name", "data", "timestamp"]):
		var new_entry = SaveDataEntry.new()
		new_entry.file_name = json["file_name"]
		new_entry.data = json["data"]
		new_entry.timestamp = Time.get_datetime_dict_from_datetime_string(json["timestamp"], false)
		return new_entry
	return null
