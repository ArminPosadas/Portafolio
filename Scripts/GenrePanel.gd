extends Panel

# Dictionary of panel containers
@onready var panels: Dictionary = {
	"Godot": $"../Projects/VBoxContainer/GodotContainer",
	"Unity": $"../Projects/VBoxContainer/UnityContainer",
	"Unreal": $"../Projects/VBoxContainer/UnrealContainer",
	"Web": $"../Projects/VBoxContainer/WebContainer"
}

# Dictionary of grid containers
@onready var grids: Dictionary = {
	"Godot": $"../Projects/VBoxContainer/GodotContainer/GridGodot",
	"Unity": $"../Projects/VBoxContainer/UnityContainer/GridUnity",
	"Unreal": $"../Projects/VBoxContainer/UnrealContainer/GridUnreal",
	"Web": $"../Projects/VBoxContainer/WebContainer/GridWeb"
}

# Reference to the Projects ScrollContainer
@onready var projects_scroll: ScrollContainer = $"../Projects"
@onready var sound_effect: AudioStreamPlayer = $"../Click"

# Signals to communicate with Inventory script
signal filter_changed(genre: String)
signal show_all_requested()

func _ready() -> void:
	for panel_name in panels.keys():
		if not panels[panel_name]:
			push_error("Panel not found: ", panel_name)
		if not grids[panel_name]:
			push_error("Grid not found: ", panel_name)

# Panel management
func show_all_panels() -> void:
	for panel in panels.values():
		if panel:
			panel.visible = true

func hide_empty_panels() -> void:
	for panel_name in panels.keys():
		var grid = grids[panel_name]
		var panel = panels[panel_name]
		
		if not grid or not panel:
			continue
		
		if grid.get_child_count() == 0:
			panel.visible = false
			continue
		
		var has_visible = false
		for child in grid.get_children():
			if child.visible:
				has_visible = true
				break
		
		panel.visible = has_visible

func toggle_panel(panel_name: String) -> void:
	if panels.has(panel_name) and panels[panel_name]:
		panels[panel_name].visible = not panels[panel_name].visible

func get_grid(panel_name: String) -> GridContainer:
	return grids.get(panel_name, null)

func get_all_grids() -> Dictionary:
	return grids

func get_all_panels() -> Dictionary:
	return panels

# Genre button handlers
func _on_tower_defense_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("TowerDefense")

func _on_ai_behaviour_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("AIBehaviour")

func _on_vfx_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("VFX")

func _on_web_page_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("WebPage")

func _on_2d_fighting_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("2DFighting")

func _on_3d_puzzle_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("3DPuzzle")

func _on_3d_rpg_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("3DRPG")

func _on_life_sim_button_pressed() -> void:
	sound_effect.play()
	_on_genre_button_pressed("LifeSim")

func _on_genre_button_pressed(genre: String) -> void:
	sound_effect.play()
	filter_changed.emit(genre)

func _on_show_all_button_pressed() -> void:
	sound_effect.play()
	show_all_requested.emit()

# Panel toggle handlers
func _on_godot_toggle_pressed() -> void:
	sound_effect.play()
	toggle_panel("Godot")

func _on_unity_toggle_pressed() -> void:
	sound_effect.play()
	toggle_panel("Unity")

func _on_unreal_toggle_pressed() -> void:
	sound_effect.play()
	toggle_panel("Unreal")

func _on_web_toggle_pressed() -> void:
	sound_effect.play()
	toggle_panel("Web")
