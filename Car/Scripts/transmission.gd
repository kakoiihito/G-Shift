extends Node





func transmission_process(delta: float, Data: RuntimeData.transmission, Values: Resource):
	var target_clutch = Input.get_action_strength("Clutch")


	if not Data.is_shifting and target_clutch > 0.95:
		if Input.is_action_just_pressed("ShiftUp"):
			if Data.current_gear < Values.gear_ratio.size() - 1:
				Data.current_gear += 1
				Data.is_shifting = true
				Data.shift_timer = 0.15 + randf() * 0.1

		if Input.is_action_just_pressed("ShiftDown"):
			if Data.current_gear > 0:
				Data.current_gear -= 1
				Data.is_shifting = true
				Data.shift_timer = 0.15 + randf() * 0.1

	if Data.is_shifting:
		Data.shift_timer -= delta
		if Data.shift_timer <= 0.0:
			Data.current_gear_ratio = Values.gear_ratio[Data.current_gear]
			Data.is_shifting = false
