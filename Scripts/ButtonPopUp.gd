extends Button

@export var popup_window: Window

func _on_pressed() -> void:
	if popup_window:
		popup_window.show()


func _on_cv_close_requested() -> void:
	if popup_window:
		popup_window.hide()
