extends Control

var template_inv_slot = preload("res://Objects/Slot1.tscn")
var item_data = {}
var current_filter = ""

@onready var godotcontainer = get_node("Projects/VBoxContainer/GodotContainer/GridGodot")
@onready var unitycontainer = get_node("Projects/VBoxContainer/UnityContainer/GridUnity")
@onready var unrealcontainer = get_node("Projects/VBoxContainer/UnrealContainer/GridUnreal")
@onready var webcontainer = get_node("Projects/VBoxContainer/WebContainer/GridWeb")

# References to the panel containers (the parent containers with the toggle buttons)
@onready var godot_panel = get_node("Projects/VBoxContainer/GodotContainer")
@onready var unity_panel = get_node("Projects/VBoxContainer/UnityContainer")
@onready var unreal_panel = get_node("Projects/VBoxContainer/UnrealContainer")
@onready var web_panel = get_node("Projects/VBoxContainer/WebContainer")

# Dictionary to store genre button references
var genre_buttons = {
	"TowerDefense": null,
	"AI Behaviour": null,
	"VFX": null,
	"WebPage": null,
	"2DFighting": null,
	"3DPuzzle": null,
	"3DRPG": null,
	"LifeSim": null
}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_item_data()
	create_inventory_slots()
	
	show_all_items()

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

# Direct button connection signals
func _on_tower_defense_button_pressed():
	_on_genre_button_pressed("TowerDefense")

func _on_ai_behaviour_button_pressed():
	_on_genre_button_pressed("AIBehaviour")

func _on_vfx_button_pressed():
	_on_genre_button_pressed("VFX")

func _on_web_page_button_pressed():
	_on_genre_button_pressed("WebPage")

func _on_2d_fighting_button_pressed():
	_on_genre_button_pressed("2DFighting")

func _on_3d_puzzle_button_pressed():
	_on_genre_button_pressed("3DPuzzle")

func _on_3d_rpg_button_pressed():
	_on_genre_button_pressed("3DRPG")

func _on_life_sim_button_pressed():
	_on_genre_button_pressed("LifeSim")

# Core filtering logic with visual feedback
func _on_genre_button_pressed(genre: String):
	if current_filter == genre:
		# If clicking the same genre, clear the filter
		current_filter = ""
		show_all_items()
		show_all_panels()  # Show all panels when filter is cleared
	else:
		# Apply new filter
		current_filter = genre
		filter_items_by_genre(genre)
		hide_empty_panels()  # Hide panels that have no visible items

# Show all items (clear filter)
func show_all_items():
	show_items_in_container(godotcontainer, true)
	show_items_in_container(unitycontainer, true)
	show_items_in_container(unrealcontainer, true)
	show_items_in_container(webcontainer, true)

# Show all panels (used when clearing filter)
func show_all_panels():
	godot_panel.visible = true
	unity_panel.visible = true
	unreal_panel.visible = true
	web_panel.visible = true

# Check and hide panels that have no visible items
func hide_empty_panels():
	# Check Godot container
	if godotcontainer.get_child_count() > 0:
		var has_visible = false
		for child in godotcontainer.get_children():
			if child.visible:
				has_visible = true
				break
		godot_panel.visible = has_visible
	else:
		godot_panel.visible = false
	
	# Check Unity container
	if unitycontainer.get_child_count() > 0:
		var has_visible = false
		for child in unitycontainer.get_children():
			if child.visible:
				has_visible = true
				break
		unity_panel.visible = has_visible
	else:
		unity_panel.visible = false
	
	# Check Unreal container
	if unrealcontainer.get_child_count() > 0:
		var has_visible = false
		for child in unrealcontainer.get_children():
			if child.visible:
				has_visible = true
				break
		unreal_panel.visible = has_visible
	else:
		unreal_panel.visible = false
	
	# Check Web container
	if webcontainer.get_child_count() > 0:
		var has_visible = false
		for child in webcontainer.get_children():
			if child.visible:
				has_visible = true
				break
		web_panel.visible = has_visible
	else:
		web_panel.visible = false

# Filter items by genre
func filter_items_by_genre(genre: String):
	# Filter items in each container
	filter_container_by_genre(godotcontainer, genre)
	filter_container_by_genre(unitycontainer, genre)
	filter_container_by_genre(unrealcontainer, genre)
	filter_container_by_genre(webcontainer, genre)

func filter_container_by_genre(container: GridContainer, genre: String):
	for child in container.get_children():
		if child.has_meta("item_data"):
			var item_genres = child.get_meta("item_data")["Genres"]
			# Check if the selected genre is in the item's genres array
			child.visible = (genre in item_genres)

func show_items_in_container(container: GridContainer, visible: bool):
	for child in container.get_children():
		child.visible = visible

# Optional: Add a "Show All" button functionality if you have one
func _on_show_all_button_pressed():
	current_filter = ""
	show_all_items()
	show_all_panels()

func create_inventory_slots():
	# Clear existing containers if needed
	clear_containers()
	
	# Loop through all items in the loaded JSON data
	for item_id in item_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		var current_item = item_data[item_id]
		
		var item_name = current_item["Name"]
		var item_description = current_item["Description"]
		var item_type = current_item["Type"]
		
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
		
		# Store item data in the slot for later use
		inv_slot_new.set_meta("item_id", item_id)
		inv_slot_new.set_meta("item_data", current_item)
		
		# Determine which container to add the slot to based on the Type
		match item_type:
			"Godot":
				godotcontainer.add_child(inv_slot_new, true)
				print("Added ", item_name, " to Godot container")
			"Unity":
				unitycontainer.add_child(inv_slot_new, true)
				print("Added ", item_name, " to Unity container")
			"Unreal":
				unrealcontainer.add_child(inv_slot_new, true)
				print("Added ", item_name, " to Unreal container")
			"Web":
				webcontainer.add_child(inv_slot_new, true)
				print("Added ", item_name, " to Web container")
			_:
				print("Unknown type '", item_type, "' for item: ", item_name)
	
	print("Created inventory slots - Godot: ", godotcontainer.get_child_count(), 
		  ", Unity: ", unitycontainer.get_child_count(), 
		  ", Unreal: ", unrealcontainer.get_child_count(),
		  ", Web: ", webcontainer.get_child_count())

func clear_containers():
	# Clear existing children if you need to refresh
	for container in [godotcontainer, unitycontainer, unrealcontainer, webcontainer]:
		for child in container.get_children():
			child.queue_free()

# Your existing toggle functions (modified to work with the new panel visibility logic)
func _on_godot_toggle_pressed() -> void:
	# Only toggle if the panel is not hidden by filter
	if godot_panel.visible:
		godot_panel.visible = !godot_panel.visible

func _on_unity_toggle_pressed() -> void:
	if unity_panel.visible:
		unity_panel.visible = !unity_panel.visible

func _on_unreal_toggle_pressed() -> void:
	if unreal_panel.visible:
		unreal_panel.visible = !unreal_panel.visible

func _on_web_toggle_pressed() -> void:
	if web_panel.visible:
		web_panel.visible = !web_panel.visible
