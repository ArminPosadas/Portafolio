extends Control

@export var template_inv_slot: PackedScene = preload("res://Objects/Slot1.tscn")

var item_data: Dictionary = {}
var current_filter: String = ""

const ITEM_DATA_PATH = "res://Data/ItemData - Sheet1.json"
const ICON_PATH = "res://Assets/Icon_Items/"

# References to sub-systems
@onready var info_panel: Panel = $InfoPanel
@onready var b_genre_panel: Panel = $BGenrePanel
@onready var projects_scroll: ScrollContainer = $Projects

# Grid references
var _grids: Dictionary = {}

func _ready() -> void:
	if b_genre_panel and b_genre_panel.has_signal("filter_changed"):
		b_genre_panel.filter_changed.connect(_on_filter_changed)
	if b_genre_panel and b_genre_panel.has_signal("show_all_requested"):
		b_genre_panel.show_all_requested.connect(_on_show_all_requested)
	
	# Get grids reference from BGenrePanel
	if b_genre_panel and b_genre_panel.has_method("get_all_grids"):
		_grids = b_genre_panel.get_all_grids()
	
	load_item_data()
	create_inventory_slots()
	show_all_items()
	
	# Info panel starts visible
	if info_panel:
		info_panel.visible = true

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
		
		# Add to appropriate grid container
		if _grids.has(item_type) and _grids[item_type]:
			_grids[item_type].add_child(inv_slot, true)
		else:
			push_warning("Unknown type '%s' or missing grid for item: %s" % [item_type, item_name])
	
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
	if info_panel and info_panel.has_method("show_item_details"):
		info_panel.show_item_details(item_id, item_info)

func clear_containers() -> void:
	for grid in _grids.values():
		if grid:
			for child in grid.get_children():
				child.queue_free()

func show_all_items() -> void:
	for grid in _grids.values():
		if grid:
			show_items_in_grid(grid, true)

func show_items_in_grid(grid: GridContainer, visible: bool) -> void:
	for child in grid.get_children():
		child.visible = visible

func filter_items_by_genre(genre: String) -> void:
	for grid in _grids.values():
		if grid:
			filter_grid_by_genre(grid, genre)

func filter_grid_by_genre(grid: GridContainer, genre: String) -> void:
	for child in grid.get_children():
		if child.has_meta("item_data"):
			var item_genres = child.get_meta("item_data").get("Genres", [])
			child.visible = genre in item_genres

func print_inventory_summary() -> void:
	var summary = []
	for type_name in _grids.keys():
		if _grids[type_name]:
			summary.append("%s: %d" % [type_name, _grids[type_name].get_child_count()])
	print("Created inventory slots - ", ", ".join(summary))

# Signal handlers
func _on_filter_changed(genre: String) -> void:
	if current_filter == genre:
		# Clear filter
		current_filter = ""
		show_all_items()
		if b_genre_panel and b_genre_panel.has_method("show_all_panels"):
			b_genre_panel.show_all_panels()
	else:
		# Apply new filter
		current_filter = genre
		filter_items_by_genre(genre)
		if b_genre_panel and b_genre_panel.has_method("hide_empty_panels"):
			b_genre_panel.hide_empty_panels()

func _on_show_all_requested() -> void:
	current_filter = ""
	show_all_items()
	if b_genre_panel and b_genre_panel.has_method("show_all_panels"):
		b_genre_panel.show_all_panels()
