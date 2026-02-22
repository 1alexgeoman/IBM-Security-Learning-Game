extends Label

func set_date() -> void:
	var time = Time.get_datetime_dict_from_system()
	var date_format1 = "%02d/%02d/%d" % [time.day, time.month, time.year]
	text = "Date: " + str(date_format1)
