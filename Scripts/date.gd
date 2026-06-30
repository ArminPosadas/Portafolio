extends Label

func _process(delta: float) -> void:
	var date = Time.get_datetime_dict_from_system()
	var year = "%04d" % date.year
	var month = "%02d" % date.month
	var day = "%02d" % date.day
	
	text = str(month, "/", day, "/", year)
