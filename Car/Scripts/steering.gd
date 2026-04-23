extends Node




func steering_proccess(delta: float, SteeringData: RuntimeData.steering, WheelData: RuntimeData.wheels, car: RigidBody3D, Values: Resource) -> void:
	
	var input_turn = Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight")
	var speed = car.linear_velocity.length()
	var speed_factor = 1.0 / (1.0 + pow(speed * Values.speed_factor_coeff, 2))
	var steering_amount = (input_turn * deg_to_rad(Values.max_tire_turn_angle) * speed_factor) / Values.steering_ratio
	
	var max_angle = deg_to_rad(Values.max_tire_turn_angle)
	var mz_to_angle = 1.0 / (Values.steering_stiffness * Values.steering_ratio)
	

	var L = Values.wheel_base
	var W = Values.track
	var R = L / tan(abs(steering_amount))

	var inner = atan(L / (R - W * 0.5))
	var outer = atan(L / (R + W * 0.5))
		

	if steering_amount > 0.0:
		SteeringData.target_fr = lerp(steering_amount, inner, Values.ackermann_factor)
		SteeringData.target_fl = lerp(steering_amount, outer, Values.ackermann_factor)
	else:
		SteeringData.target_fl = lerp(steering_amount, -inner, Values.ackermann_factor)
		SteeringData.target_fr = lerp(steering_amount, -outer, Values.ackermann_factor)
	
	SteeringData.target_fl = clamp(SteeringData.target_fl - WheelData.aligning_torque[0] * mz_to_angle, -max_angle, max_angle) * 0.8
	SteeringData.target_fr = clamp(SteeringData.target_fr - WheelData.aligning_torque[1] * mz_to_angle, -max_angle, max_angle) * 0.8
		
	car.fl_wheel.rotation.y = move_toward(
		car.fl_wheel.rotation.y,
		SteeringData.target_fl,
		Values.tire_turn_speed * delta
	)
	car.fr_wheel.rotation.y = move_toward(
		car.fr_wheel.rotation.y,
		SteeringData.target_fr,
		Values.tire_turn_speed * delta
	)
