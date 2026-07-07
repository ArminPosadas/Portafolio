extends Button

@onready var sound_effect: AudioStreamPlayer = $"../../../../Click"

func _on_pressed() -> void:
	sound_effect.play()
	SceneTransition.change_scene("res://Scenes/ProjectsWindows.tscn")
