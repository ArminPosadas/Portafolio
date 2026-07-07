extends Button

@export var popup_window: Window
@onready var sound_effect: AudioStreamPlayer = $"../../../../Click"

func _on_pressed() -> void:
	sound_effect.play()
	if popup_window:
		popup_window.show()


func _on_about_me_close_requested() -> void:
	if popup_window:
		popup_window.hide()


func _on_contacts_close_requested() -> void:
	if popup_window:
		popup_window.hide()


func _on_cv_close_requested() -> void:
	if popup_window:
		popup_window.hide()
