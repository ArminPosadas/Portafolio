extends Control

var template_inv_slot = preload("res://Objects/Slot1.tscn")
var item_data = {}

@onready var gridcontainer = get_node("Projects/VBoxContainer/ScrollContainer/GridContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	load_item_data()
	create_inventory_slots()

func load_item_data():
	var json_file = FileAccess.open("res://Data/ItemData - Sheet1.json", FileAccess.READ)
	if json_file:
		var json_text = json_file.get_as_text()
		var json_parse = JSON.new()
		var parse_result = json_parse.parse(json_text)
		
		if parse_result == OK:
			item_data = json_parse.data
			print("Loaded ", item_data.size(), " items successfully")
		else:
			print("Error parsing JSON: ", json_parse.get_error_message())
	else:
		print("Failed to open JSON file")

func create_inventory_slots():
	# Loop through all items in the loaded JSON data
	for item_id in item_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		var current_item = item_data[item_id]
		
		var item_name = current_item["Name"]
		var item_description = current_item["Description"]
		var item_type = current_item["Type"]
		var item_genre = current_item["Genre"]
		
		# Set the icon texture
		var icon_path = "res://Assets/Icon_Items/" + item_name + ".png"
		var icon_texture = null
		
		if ResourceLoader.exists(icon_path):
			icon_texture = load(icon_path)
		else:
			print("Icon not found: ", icon_path)
		
		# Set the icon in the inventory slot
		if inv_slot_new.has_node("Icon") and icon_texture:
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
		
		# Set the name label
		if inv_slot_new.has_node("Name"):
			inv_slot_new.get_node("Name").text = item_name
		
		# Set the description label (optional)
		if inv_slot_new.has_node("Description"):
			inv_slot_new.get_node("Description").text = item_description
		
		# Store item data in the slot for later use (Tags and shorting)
		inv_slot_new.set_meta("item_id", item_id)
		inv_slot_new.set_meta("item_data", current_item)
		
		gridcontainer.add_child(inv_slot_new, true)
	
	print("Created ", item_data.size(), " inventory slots")
