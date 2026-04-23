extends Node


func abs_proccess(delta: float, BrakeData: RuntimeData.brake, WheelData: RuntimeData.wheels, Values: Resource) -> void:
	if Values.ABS == true:
		for i in range(4):
			if clamp(WheelData.slip_ratio[i], -1.0, 1.0) > Values.abs_slip_threshold:
				BrakeData.abs_active[i] = true
				BrakeData.wheel_brake_torque[i] *= exp(Values.abs_decay_rate * delta)
			else:
				BrakeData.abs_active[i] = false
				
func tc_proccess(delta: float, EngineData: RuntimeData.engine, WheelData: RuntimeData.wheels, Values: Resource) -> void:
	if Values.TC == true:
		for i in range(4):
			if clamp(WheelData.slip_ratio[i], -1.0, 1.0) > Values.tc_slip_threshold:
				EngineData.wheel_engine_torque[i] *= exp(Values.tc_decay_rate * delta)


	
func stability_proccess() -> void:
	pass # for the future. seems i need to do more research.
