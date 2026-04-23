extends Node

var item_data = {}

func _ready():
	var item_data_file = FileAccess.open("res://Data/ItemData - Sheet1.json", FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json
