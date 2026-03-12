extends Node2D

@onready var popup = $Window

func _on_button_pressed() -> void:
	popup.show()


func _on_window_close_requested() -> void:
	popup.hide()
