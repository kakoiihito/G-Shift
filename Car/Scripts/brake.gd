extends Node

@export var car: RigidBody3D
@onready var Values: Resource
var wheel_brake_torque = Data.wheel_brake_torque
var brake_torque: float 


func _ready() -> void:
	var brake_wheels = [Values.FL_torque_brake, Values.FR_torque_brake, Values.RL_torque_brake, Values.RR_torque_brake]
	for i in range(4):
		if brake_wheels[i] == true:
			Data.active_wheels_brake += 1

func brake_proccess() -> void:
	var brake_wheels = [Values.FL_torque_brake, Values.FR_torque_brake, Values.RL_torque_brake, Values.RR_torque_brake]
	var input_brake = Input.get_action_strength("Brake")

	if input_brake > 0.0:
		brake_torque = (input_brake * Values.max_brake_torque) / Data.active_wheels_brake
		for i in range(4):
			if brake_wheels[i] and not Data.abs_active[i]:
				Data.wheel_brake_torque[i] = brake_torque
	else:
		for i in range(4):
			Data.abs_active[i] = false
			Data.wheel_brake_torque[i] = 0.0
