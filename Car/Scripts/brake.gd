extends Node






func brake_proccess(Data: RuntimeData.brake, Values: Resource) -> void:
	var brake_wheels = [Values.FL_torque_brake, Values.FR_torque_brake, Values.RL_torque_brake, Values.RR_torque_brake]
	var input_brake = Input.get_action_strength("Brake")

	for i in range(4):
		if brake_wheels[i] == true:
			Data.active_wheels_brake += 1

	if input_brake > 0.0:
		Data.brake_torque = (input_brake * Values.max_brake_torque) / Data.active_wheels_brake
		for i in range(4):
			if brake_wheels[i] and not Data.abs_active[i]:
				Data.wheel_brake_torque[i] = Data.brake_torque
	else:
		for i in range(4):
			Data.abs_active[i] = false
			Data.wheel_brake_torque[i] = 0.0
