extends Node2D

var template_inv_slot = preload("res://Objects/Link_slot1.tscn")
var link_data = {}

@onready var gridcontainer = get_node("Contacts/MarginContainer/ScrollContainer/GridContainer")

func _ready():
	load_link_data()
	create_inventory_slots()

func load_link_data():
	var json_file = FileAccess.open("res://Data/LinkData - Sheet1.json", FileAccess.READ)
	if json_file:
		var json_text = json_file.get_as_text()
		var json_parse = JSON.new()
		var parse_result = json_parse.parse(json_text)
		
		if parse_result == OK:
			link_data = json_parse.data
			print("Loaded ", link_data.size(), " items successfully")
		else:
			print("Error parsing JSON: ", json_parse.get_error_message())
	else:
		print("Failed to open JSON file")
		
func create_inventory_slots():
	for item_id in link_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		var current_item = link_data[item_id]
		
		var item_name = current_item["Name"]
		var item_icon = current_item["Icon"]
		var item_url = current_item["URL"]
		
		# Set the LinkButton text and URL
		var link_button = inv_slot_new.get_node("LinkButton") # Adjust the node path as needed
		if link_button:
			link_button.text = item_name
			link_button.uri = item_url  # For URL property in LinkButton
		
		# Set the icon if you have an Icon node
		var icon_path = "res://Assets/Icon_Items/" + item_icon + ".png"
		var icon_texture = null
		
		if ResourceLoader.exists(icon_path):
			icon_texture = load(icon_path)
		else:
			print("Icon not found: ", icon_path)
		
		# Check for Icon node (adjust path as needed)
		if inv_slot_new.has_node("Icon") and icon_texture:
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
		
		# Add to grid container
		gridcontainer.add_child(inv_slot_new)
