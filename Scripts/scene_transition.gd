extends CanvasLayer

func change_scene(target: String) -> void:
	# Close all popup windows before transitioning
	_close_all_popups()
	
	$AnimationPlayer.play("dissolve")
	await ($AnimationPlayer.animation_finished)
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")

func _close_all_popups() -> void:
	# Get all windows in the scene
	var windows = get_tree().get_nodes_in_group("popup_windows")
	for window in windows:
		if window is Window and window.visible:
			window.hide()
