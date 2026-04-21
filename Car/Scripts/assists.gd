extends Node

@onready var Values: Resource
@export var car: RigidBody3D

func abs_proccess(delta: float) -> void:
	if Values.ABS == true:
		for i in range(4):
			if clamp(Data.slip_ratio[i], -1.0, 1.0) > Values.abs_slip_threshold:
				Data.abs_active[i] = true
				Data.wheel_brake_torque[i] *= exp(Values.abs_decay_rate * delta)
			else:
				Data.abs_active[i] = false
				
func tc_proccess(delta: float) -> void:
	if Values.TC == true:
		for i in range(4):
			if clamp(Data.slip_ratio[i], -1.0, 1.0) > Values.tc_slip_threshold:
				Data.wheel_engine_torque[i] *= exp(Values.tc_decay_rate * delta)


	
func stability_proccess() -> void:
	pass # for the future. seems i need to do more research.
