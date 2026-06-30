extends Label

func _process(delta: float) -> void:
	var time = Time.get_time_dict_from_system()
	var display_hour = time.hour % 12
	if display_hour == 0:
		display_hour = 12
	var hour = "%02d" % display_hour
	var minute = "%02d" % time.minute
	var daytime = " AM" if time.hour < 12 else " PM"
	
	text = str(hour, ":", minute, daytime)
