class_name RuntimeData
extends Resource


class suspension:
	var wheel_spring_force = [Vector3(), Vector3(), Vector3(), Vector3()]
	var compression = [0.0, 0.0, 0.0, 0.0]
	
class brake:
	var wheel_brake_torque = [0.0, 0.0, 0.0, 0.0]
	var abs_active = [false, false, false, false]
	var active_wheels_brake: int
	var brake_torque: float 

class engine:
	var wheel_engine_torque = [0.0, 0.0, 0.0, 0.0]
	var engine_rpm: float
	var engine_angular_velocity: float
	var clutch_torque_on_engine: float
	var engine_stalled: bool
	var engine_driven_count: int 

class transmission:
	var is_shifting = false
	var current_gear_ratio: float
	var shift_timer = 0.0
	var current_gear = 1

class wheels:
	var wheel_angular_velocity = [0.0, 0.0, 0.0, 0.0]
	var F_max = [0.0, 0.0, 0.0, 0.0]
	var longitude_force = [0.0, 0.0, 0.0, 0.0]
	var lateral_force = [0.0, 0.0, 0.0, 0.0]
	var slip_ratio = [0.0, 0.0, 0.0, 0.0]
	var aligning_torque = [0.0, 0.0, 0.0, 0.0]
	var camber:float
	var slip_angle = [0.0, 0.0, 0.0, 0.0]

class steering:
	var target_fl := 0.0
	var target_fr := 0.0
