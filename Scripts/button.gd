extends Button

@onready var click_effect: AudioStreamPlayer = $"../../Click"
@onready var hover_effect: AudioStreamPlayer = $"../../Hover"

func _on_pressed() -> void:
	click_effect.play()
	SceneTransition.change_scene("res://Scenes/MainMenu.tscn")


func _on_mouse_entered() -> void:
	hover_effect.play()
