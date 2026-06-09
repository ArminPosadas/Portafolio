extends Panel

@onready var description_label: Label = $Descripcion/Label
@onready var video_player: VideoStreamPlayer = $Video/VideoStreamPlayer
@onready var animation_player: AnimationPlayer = $Transition

var _pending_item_id: String = ""
var _pending_item_info: Dictionary = {}
var active: bool = false

const VIDEO_PATH = "res://Assets/Video/"

func _ready() -> void:
	visible = true

# Public method to show item details
func show_item_details(item_id: String, item_info: Dictionary) -> void:
	_pending_item_id = item_id
	_pending_item_info = item_info
	
	if animation_player and animation_player.has_animation("hidden"):
		if not animation_player.is_connected("animation_finished", Callable(self, "_on_transition_animation_finished")):
			animation_player.connect("animation_finished", Callable(self, "_on_transition_animation_finished"))
		
		if not active:
			animation_player.play("move_info")
		else:
			animation_player.play("hidden")
	else:
		_update_info_panel_content(item_id, item_info)

func _on_transition_animation_finished(anim_name: String) -> void:
	if anim_name == "move_info":
		active = true
		if _pending_item_info.is_empty():
			return
		_update_info_panel_content(_pending_item_id, _pending_item_info)
		_pending_item_id = ""
		_pending_item_info = {}
	elif anim_name == "hidden":
		if _pending_item_info.is_empty():
			return
		_update_info_panel_content(_pending_item_id, _pending_item_info)
		animation_player.play_backwards("hidden")
		_pending_item_id = ""
		_pending_item_info = {}

func _update_info_panel_content(_item_id: String, item_info: Dictionary) -> void:
	if description_label:
		description_label.text = item_info.get("Description", "No description available")
	
	if not video_player:
		return
	
	video_player.stop()
	var video_filename = item_info.get("Video", "")
	
	if video_filename.is_empty():
		video_player.stream = null
		return
	
	var video_path = VIDEO_PATH + video_filename
	
	if ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		video_player.play()
	else:
		push_warning("Video not found: ", video_path)
		video_player.stream = null

func hide_panel() -> void:
	active = false
