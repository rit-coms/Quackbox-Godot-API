@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	#add_custom_type("QuackboxAPI", "Node", preload("library.gd"), preload("icon.svg"))
	add_autoload_singleton("QuackboxApi", "quackbox_api.gd")
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	#remove_custom_type("QuackboxAPI")
	remove_autoload_singleton("QuackboxApi")
	pass
