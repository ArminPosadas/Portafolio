extends Panel

@onready var description_label: Label = $Descripcion/Label
@onready var video_player: VideoStreamPlayer = $Video/VideoStreamPlayer
@onready var animation_player: AnimationPlayer = $Transition

var _pending_item_id: String = ""
var _pending_item_info: Dictionary = {}
var active: bool = false
var _is_closing: bool = false  # New flag to track closing state

const VIDEO_PATH = "res://Assets/Video/"

func _ready() -> void:
	visible = true

# Public method to show item details
func show_item_details(item_id: String, item_info: Dictionary) -> void:
	print("Show item details called for: ", item_info.get("Name", "Unknown"))
	print("Active state: ", active)
	
	_pending_item_id = item_id
	_pending_item_info = item_info
	
	if animation_player:
		# Ensure connection is established only once
		if not animation_player.is_connected("animation_finished", Callable(self, "_on_transition_animation_finished")):
			animation_player.connect("animation_finished", Callable(self, "_on_transition_animation_finished"))
		
		if not active:
			if animation_player.has_animation("move_info"):
				print("Playing move_info animation")
				_is_closing = false  # Reset closing flag
				animation_player.play("move_info")
			else:
				print("ERROR: move_info animation not found!")
				_update_info_panel_content(item_id, item_info)
		else:
			if animation_player.has_animation("hidden"):
				print("Playing hidden animation")
				animation_player.play("hidden")
			else:
				print("ERROR: hidden animation not found!")
				_update_info_panel_content(item_id, item_info)
	else:
		print("ERROR: animation_player is null!")
		_update_info_panel_content(item_id, item_info)

func _on_transition_animation_finished(anim_name: String) -> void:
	print("Animation finished: ", anim_name, " | Is closing: ", _is_closing)
	
	# If we're closing the panel, don't update content or set active to true
	if _is_closing:
		print("Skipping content update because panel is closing")
		_is_closing = false  # Reset the flag
		return
	
	if anim_name == "move_info":
		active = true
		if not _pending_item_info.is_empty():
			_update_info_panel_content(_pending_item_id, _pending_item_info)
			# Clean up pending data
			_pending_item_id = ""
			_pending_item_info = {}
		else:
			print("Warning: No pending item info for move_info animation")
			
	elif anim_name == "hidden":
		if not _pending_item_info.is_empty():
			_update_info_panel_content(_pending_item_id, _pending_item_info)
			if animation_player.has_animation("hidden"):
				animation_player.play_backwards("hidden")
			# Clean up pending data
			_pending_item_id = ""
			_pending_item_info = {}

func _update_info_panel_content(_item_id: String, item_info: Dictionary) -> void:
	print("Updating info panel content for: ", item_info.get("Name", "Unknown"))
	
	if description_label:
		description_label.text = item_info.get("Description", "No description available")
		print("Description set to: ", description_label.text)
	
	if not video_player:
		print("Warning: video_player not found")
		return
	
	video_player.stop()
	var video_filename = item_info.get("Video", "")
	
	if video_filename.is_empty():
		print("No video filename provided")
		video_player.stream = null
		return
	
	var video_path = VIDEO_PATH + video_filename
	print("Looking for video at: ", video_path)
	
	if ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		video_player.play()
		print("Video playing")
	else:
		push_warning("Video not found: ", video_path)
		video_player.stream = null

func hide_panel() -> void:
	print("Hiding panel, setting active to false")
	active = false

func _on_close_pressed() -> void:
	_is_closing = true  # Set flag to prevent content update
	animation_player.play_backwards("move_info")
	active = false
