extends Button

@export var popup_window: Window
@onready var click_effect: AudioStreamPlayer = $"../../../../Click"
@onready var hover_effect: AudioStreamPlayer = $"../../../../Hover"

func _on_pressed() -> void:
	click_effect.play()
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


func _on_mouse_entered() -> void:
	hover_effect.play()
