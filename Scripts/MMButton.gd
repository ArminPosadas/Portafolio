extends Button

@export var menu_bar: Control
@export var raised_position: Vector2
@export var animation_duration: float = 0.5
@export var cooldown_time: float = 0.8

var lowered_position: Vector2
var is_raised: bool = false
var on_cooldown: bool = false
var tween: Tween


func _ready() -> void:
	if menu_bar:
		lowered_position = menu_bar.position
		
		if raised_position == Vector2.ZERO:
			raised_position = Vector2(lowered_position.x, lowered_position.y - 200)
	
	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if on_cooldown or not menu_bar:
		return
	
	on_cooldown = true
	
	if tween:
		tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	
	if is_raised:
		tween.tween_property(menu_bar, "position", lowered_position, animation_duration)
	else:
		tween.tween_property(menu_bar, "position", raised_position, animation_duration)
	
	is_raised = !is_raised
	
	var cooldown_timer = get_tree().create_timer(cooldown_time)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)


func _on_cooldown_timeout() -> void:
	on_cooldown = false


func set_positions(lowered: Vector2, raised: Vector2) -> void:
	lowered_position = lowered
	raised_position = raised
	
	if menu_bar:
		menu_bar.position = lowered_position if not is_raised else raised_position
