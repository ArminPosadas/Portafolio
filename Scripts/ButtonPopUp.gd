extends Button

@export var popup_window: Window
@onready var click_effect: AudioStreamPlayer = $"../../../../Click"
@onready var hover_effect: AudioStreamPlayer = $"../../../../Hover"

func _ready() -> void:
	# Add popup window to group for easy access
	if popup_window:
		popup_window.add_to_group("popup_windows")

func _on_pressed() -> void:
	click_effect.play()
	if popup_window:
		if popup_window.visible:
			popup_window.move_to_center()
			popup_window.grab_focus()
		else:
			popup_window.show()

func _on_mouse_entered() -> void:
	hover_effect.play()

func _on_proyects_pressed() -> void:
	click_effect.play()
	SceneTransition.change_scene("res://Scenes/ProjectsWindows.tscn")
