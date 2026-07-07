extends Panel

@onready var description_label: Label = $Descripcion/Label
@onready var video_player: VideoStreamPlayer = $Video/VideoStreamPlayer
@onready var animation_player: AnimationPlayer = $Transition
@onready var video_counter_label: Label = $CurrentVideo/VideoCounterLabel
@onready var sound_effect: AudioStreamPlayer = $"../Click"

var _pending_item_id: String = ""
var _pending_item_info: Dictionary = {}
var active: bool = false
var _is_closing: bool = false  # New flag to track closing state

# Video navigation variables
var _current_video_index: int = 0
var _video_list: Array = []
var _current_item_id: String = ""

const VIDEO_PATH = "res://Assets/Video/"

func _ready() -> void:
	visible = true
	
	# Hide video counter initially
	if video_counter_label:
		video_counter_label.visible = false

# Public method to show item details
func show_item_details(item_id: String, item_info: Dictionary) -> void:
	sound_effect.play()
	_pending_item_id = item_id
	_pending_item_info = item_info
	
	if animation_player:
		# Ensure connection is established only once
		if not animation_player.is_connected("animation_finished", Callable(self, "_on_transition_animation_finished")):
			animation_player.connect("animation_finished", Callable(self, "_on_transition_animation_finished"))
		
		if not active:
			if animation_player.has_animation("move_info"):
				_is_closing = false  # Reset closing flag
				animation_player.play("move_info")
			else:
				_update_info_panel_content(item_id, item_info)
		else:
			if animation_player.has_animation("hidden"):
				animation_player.play("hidden")
			else:
				_update_info_panel_content(item_id, item_info)
	else:
		_update_info_panel_content(item_id, item_info)

func _on_transition_animation_finished(anim_name: String) -> void:
	print("Animation finished: ", anim_name, " | Is closing: ", _is_closing)
	
	# If we're closing the panel, don't update content or set active to true
	if _is_closing:
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

func _update_info_panel_content(item_id: String, item_info: Dictionary) -> void:
	# Store current item info for video navigation
	_current_item_id = item_id
	
	if description_label:
		description_label.text = item_info.get("Description", "No description available")
		print("Description set to: ", description_label.text)
	
	# Get video list from the new "Videos" field
	_video_list = item_info.get("Videos", [])
	_current_video_index = 0
	
	# Update video buttons state (using the buttons directly by name/path if needed)
	_update_video_buttons()
	
	# Load and play first video
	_load_video_at_index(0)

func _load_video_at_index(index: int) -> void:
	if not video_player:
		print("Warning: video_player not found")
		return
	
	# Validate index
	if _video_list.is_empty() or index < 0 or index >= _video_list.size():
		print("No valid video at index: ", index)
		video_player.stop()
		video_player.stream = null
		
		# Hide counter if no videos
		if video_counter_label:
			video_counter_label.visible = false
		return
	
	# Show counter if we have videos
	if video_counter_label:
		video_counter_label.visible = true
		video_counter_label.text = str(index + 1) + "/" + str(_video_list.size())
	
	video_player.stop()
	var video_filename = _video_list[index]
	
	if video_filename.is_empty():
		print("Empty video filename at index: ", index)
		video_player.stream = null
		return
	
	var video_path = VIDEO_PATH + video_filename
	print("Looking for video at: ", video_path)
	
	if ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		video_player.play()
		print("Video playing: ", video_filename)
	else:
		push_warning("Video not found: ", video_path)
		video_player.stream = null

func _update_video_buttons() -> void:
	# Get button references
	var prev_button = get_node_or_null("InfoPanel/PrevVideoButton")
	var next_button = get_node_or_null("InfoPanel/NextVideoButton")
	
	if not prev_button or not next_button:
		return
	
	var has_videos = not _video_list.is_empty()
	
	if has_videos:
		# Enable/disable based on current index
		prev_button.disabled = (_video_list.size() <= 1)
		next_button.disabled = (_video_list.size() <= 1)
	else:
		# No videos, disable both buttons
		prev_button.disabled = true
		next_button.disabled = true

func _on_prev_video_pressed() -> void:
	sound_effect.play()
	if _video_list.is_empty():
		return
	
	# Go to previous video, wrap around to last if at first
	_current_video_index -= 1
	if _current_video_index < 0:
		_current_video_index = _video_list.size() - 1
	
	_load_video_at_index(_current_video_index)
	_update_video_buttons()

func _on_next_video_pressed() -> void:
	sound_effect.play()
	if _video_list.is_empty():
		return
	
	# Go to next video, wrap around to first if at last
	_current_video_index += 1
	if _current_video_index >= _video_list.size():
		_current_video_index = 0
	
	_load_video_at_index(_current_video_index)
	_update_video_buttons()

func hide_panel() -> void:
	print("Hiding panel, setting active to false")
	active = false

func _on_close_pressed() -> void:
	sound_effect.play()
	_is_closing = true  # Set flag to prevent content update
	animation_player.play_backwards("move_info")
	active = false
	# Reset video state
	_video_list = []
	_current_video_index = 0
	
	var prev_button = get_node_or_null("InfoPanel/PrevVideoButton")
	var next_button = get_node_or_null("InfoPanel/NextVideoButton")
	
	if prev_button:
		prev_button.disabled = true
	if next_button:
		next_button.disabled = true
	if video_counter_label:
		video_counter_label.visible = false
