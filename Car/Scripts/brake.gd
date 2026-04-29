extends Node

var input_brake := 0.0

func brake_process(delta: float, Data: RuntimeData.brake, Values: Resource) -> void:
	var brake_wheels = [Values.FL_torque_brake, Values.FR_torque_brake, Values.RL_torque_brake, Values.RR_torque_brake]
	var target_brake = Input.get_action_strength("Brake")
	var brake_rate = 8.0 if target_brake > input_brake else 12.0
	input_brake = move_toward(input_brake, target_brake, brake_rate * delta)

	# Reset and recount active brake wheels each frame
	Data.active_wheels_brake = 0
	for i in range(4):
		if brake_wheels[i] == true:
			Data.active_wheels_brake += 1

	if Data.active_wheels_brake == 0:
		return

	if input_brake > 0.0:
		Data.brake_torque = (input_brake * Values.max_brake_torque) / Data.active_wheels_brake
		for i in range(4):
			if brake_wheels[i] and Data.abs_active[i] == false:
				Data.wheel_brake_torque[i] = Data.brake_torque
			else:
				Data.wheel_brake_torque[i] = 0.0  # ABS pulse or inactive wheel
	else:
		for i in range(4):
			Data.abs_active[i] = false
			Data.wheel_brake_torque[i] = 0.0
