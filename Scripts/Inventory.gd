extends Control

const ITEM_DATA_PATH = "res://Data/ItemData - Sheet1.json"
const ICON_PATH = "res://Assets/Icon_Items/"
const VIDEO_PATH = "res://Assets/Video/"

@export var template_inv_slot: PackedScene = preload("res://Objects/Slot1.tscn")

var item_data: Dictionary = {}
var current_filter: String = ""

# UI References - Using @onready with safer get_node patterns
@onready var info_panel: Panel = $InfoPanel
@onready var description_label: Label = $InfoPanel/Descripcion/Label
@onready var video_player: VideoStreamPlayer = $InfoPanel/Video/VideoStreamPlayer
@onready var animation_player: AnimationPlayer = $InfoPanel/AnimationPlayer

# Container references
@onready var containers: Dictionary = {
	"Godot": $Projects/VBoxContainer/GodotContainer/GridGodot,
	"Unity": $Projects/VBoxContainer/UnityContainer/GridUnity,
	"Unreal": $Projects/VBoxContainer/UnrealContainer/GridUnreal,
	"Web": $Projects/VBoxContainer/WebContainer/GridWeb
}

@onready var panels: Dictionary = {
	"Godot": $Projects/VBoxContainer/GodotContainer,
	"Unity": $Projects/VBoxContainer/UnityContainer,
	"Unreal": $Projects/VBoxContainer/UnrealContainer,
	"Web": $Projects/VBoxContainer/WebContainer
}

func _ready() -> void:
	load_item_data()
	create_inventory_slots()
	show_all_items()
	info_panel.visible = false

func load_item_data() -> void:
	var json_file = FileAccess.open(ITEM_DATA_PATH, FileAccess.READ)
	if not json_file:
		push_error("Failed to open JSON file: ", ITEM_DATA_PATH)
		return
	
	var json_text = json_file.get_as_text()
	var json_parse = JSON.new()
	var parse_result = json_parse.parse(json_text)
	
	if parse_result == OK:
		item_data = json_parse.data
		print("Loaded ", item_data.size(), " items successfully")
	else:
		push_error("Error parsing JSON: ", json_parse.get_error_message())

func show_item_details(item_id: String, item_info: Dictionary) -> void:
	if not info_panel:
		return
	
	info_panel.visible = true
	
	if animation_player and animation_player.has_animation("hidden"):
		# Store pending data and play animation
		animation_player.set_meta("pending_item_id", item_id)
		animation_player.set_meta("pending_item_info", item_info)
		
		if not animation_player.is_connected("animation_finished", Callable(self, "_on_hidden_animation_finished")):
			animation_player.connect("animation_finished", Callable(self, "_on_hidden_animation_finished"))
		
		animation_player.play("hidden")
	else:
		update_info_panel_content(item_id, item_info)

func _on_hidden_animation_finished(anim_name: String) -> void:
	if anim_name != "hidden":
		return
	
	var item_id = animation_player.get_meta("pending_item_id", "")
	var item_info = animation_player.get_meta("pending_item_info", {})
	
	if item_info.is_empty():
		return
	
	update_info_panel_content(item_id, item_info)
	animation_player.play_backwards("hidden")
	
	# Clean up metadata
	animation_player.remove_meta("pending_item_id")
	animation_player.remove_meta("pending_item_info")

func update_info_panel_content(_item_id: String, item_info: Dictionary) -> void:
	if description_label:
		description_label.text = item_info.get("Description", "No description available")
	
	if not video_player:
		return
	
	video_player.stop()
	var video_filename = item_info.get("Video", "")
	
	if video_filename.is_empty():
		video_player.stream = null
		return
	
	var video_path = VIDEO_PATH + video_filename
	
	if ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		video_player.play()
	else:
		push_warning("Video not found: ", video_path)
		video_player.stream = null

# Genre button handlers
func _on_tower_defense_button_pressed() -> void:
	_on_genre_button_pressed("TowerDefense")

func _on_ai_behaviour_button_pressed() -> void:
	_on_genre_button_pressed("AIBehaviour")

func _on_vfx_button_pressed() -> void:
	_on_genre_button_pressed("VFX")

func _on_web_page_button_pressed() -> void:
	_on_genre_button_pressed("WebPage")

func _on_2d_fighting_button_pressed() -> void:
	_on_genre_button_pressed("2DFighting")

func _on_3d_puzzle_button_pressed() -> void:
	_on_genre_button_pressed("3DPuzzle")

func _on_3d_rpg_button_pressed() -> void:
	_on_genre_button_pressed("3DRPG")

func _on_life_sim_button_pressed() -> void:
	_on_genre_button_pressed("LifeSim")

func _on_genre_button_pressed(genre: String) -> void:
	if current_filter == genre:
		current_filter = ""
		show_all_items()
		show_all_panels()
	else:
		current_filter = genre
		filter_items_by_genre(genre)
		hide_empty_panels()

func show_all_items() -> void:
	for container in containers.values():
		show_items_in_container(container, true)

func show_all_panels() -> void:
	for panel in panels.values():
		panel.visible = true

func hide_empty_panels() -> void:
	for panel_name in panels.keys():
		var container = containers[panel_name]
		var panel = panels[panel_name]
		
		if container.get_child_count() == 0:
			panel.visible = false
			continue
		
		var has_visible = false
		for child in container.get_children():
			if child.visible:
				has_visible = true
				break
		
		panel.visible = has_visible

func filter_items_by_genre(genre: String) -> void:
	for container in containers.values():
		filter_container_by_genre(container, genre)

func filter_container_by_genre(container: GridContainer, genre: String) -> void:
	for child in container.get_children():
		if child.has_meta("item_data"):
			var item_genres = child.get_meta("item_data").get("Genres", [])
			child.visible = genre in item_genres

func show_items_in_container(container: GridContainer, visible: bool) -> void:
	for child in container.get_children():
		child.visible = visible

func _on_show_all_button_pressed() -> void:
	current_filter = ""
	show_all_items()
	show_all_panels()

func create_inventory_slots() -> void:
	clear_containers()
	
	for item_id in item_data.keys():
		var inv_slot = template_inv_slot.instantiate()
		var current_item = item_data[item_id]
		var item_name = current_item.get("Name", "")
		var item_type = current_item.get("Type", "")
		
		if item_name.is_empty() or item_type.is_empty():
			push_warning("Item missing required data: ", item_id)
			continue
		
		setup_slot_icon(inv_slot, item_name)
		setup_slot_labels(inv_slot, current_item)
		setup_slot_metadata(inv_slot, item_id, current_item)
		setup_slot_connection(inv_slot, item_id, current_item)
		
		# Add to appropriate container
		if containers.has(item_type):
			containers[item_type].add_child(inv_slot, true)
		else:
			push_warning("Unknown type '%s' for item: %s" % [item_type, item_name])
	
	print_inventory_summary()

func setup_slot_icon(slot: Node, item_name: String) -> void:
	var icon_node = slot.get_node_or_null("Icon")
	if not icon_node:
		return
	
	var icon_path = ICON_PATH + item_name + ".png"
	if ResourceLoader.exists(icon_path):
		icon_node.texture = load(icon_path)
	else:
		push_warning("Icon not found: ", icon_path)

func setup_slot_labels(slot: Node, item_info: Dictionary) -> void:
	var name_label = slot.get_node_or_null("Name")
	if name_label:
		name_label.text = item_info.get("Name", "")
	
	var summary_label = slot.get_node_or_null("Summary")
	if summary_label:
		summary_label.text = item_info.get("Summary", "")

func setup_slot_metadata(slot: Node, item_id: String, item_info: Dictionary) -> void:
	slot.set_meta("item_id", item_id)
	slot.set_meta("item_data", item_info)

func setup_slot_connection(slot: Node, item_id: String, item_info: Dictionary) -> void:
	if slot is BaseButton:
		slot.pressed.connect(_on_slot_button_pressed.bind(item_id, item_info))
		return
	
	var button = slot.get_node_or_null("Button")
	if button and button is BaseButton:
		button.pressed.connect(_on_slot_button_pressed.bind(item_id, item_info))

func _on_slot_button_pressed(item_id: String, item_info: Dictionary) -> void:
	print("Slot pressed: ", item_info.get("Name", "Unknown"))
	show_item_details(item_id, item_info)

func clear_containers() -> void:
	for container in containers.values():
		for child in container.get_children():
			child.queue_free()

func print_inventory_summary() -> void:
	var summary = []
	for type_name in containers.keys():
		summary.append("%s: %d" % [type_name, containers[type_name].get_child_count()])
	print("Created inventory slots - ", ", ".join(summary))

# Panel toggle handlers
func _on_godot_toggle_pressed() -> void:
	toggle_panel("Godot")

func _on_unity_toggle_pressed() -> void:
	toggle_panel("Unity")

func _on_unreal_toggle_pressed() -> void:
	toggle_panel("Unreal")

func _on_web_toggle_pressed() -> void:
	toggle_panel("Web")

func toggle_panel(panel_name: String) -> void:
	if panels.has(panel_name):
		panels[panel_name].visible = not panels[panel_name].visible
