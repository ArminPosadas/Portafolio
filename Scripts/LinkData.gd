extends Node

var link_data = {}

func _ready():
	var link_data_file = FileAccess.open("res://Data/LinkData - Sheet1.json", FileAccess.READ)
	var link_data_json = JSON.parse_string(link_data_file.get_as_text())
	link_data_file.close()
	link_data = link_data_json
