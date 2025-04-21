extends Node

func _ready():
	QuackboxApi.add_leaderboard_entry("Woo", 0.13453, 1)
	QuackboxApi.add_leaderboard_entry("Woo", 0.13421, 1)
	QuackboxApi.add_save_data("example_save", JSON.stringify({ "my bad": "lmao", "huh": 0.345, "0.24314": false}), 0)
	
	var file_names = await QuackboxApi.get_save_file_names(0)
	var save = await QuackboxApi.get_save_data_file("example_save", 0)
	var lb_entries = await QuackboxApi.get_global_leaderboard_entries("Woo", 100)
	print(file_names)
	print(save)
	
