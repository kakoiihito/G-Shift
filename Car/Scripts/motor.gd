extends Node

func motor_process(delta: float, EngineData: RuntimeData.engine, TransmissionData: RuntimeData.transmission, WheelData: RuntimeData.wheels, Values: Resource) -> void:
	
	
	var torque_curve = Values.torque_curve
	var driven_count = EngineData.engine_driven_count
	var drivetrain_ratio = TransmissionData.current_gear_ratio * Values.final_drive
	
	var throttle_input := Input.get_action_strength("Gas")
	
	var clutch_input := Input.get_action_strength("Clutch")
	var normalized = clamp((1.0 - clutch_input - 0.3) / 0.4, 0.0, 1.0)
	var clutch_engagement = normalized * normalized * (3.0 - 2.0 * normalized)
	
	var angular_velocity_sum: float = 0.0
	var target_engine_ang_vel: float
	
	# Angular velocity addition (for engine angular velocity)
	
	var driven_wheels = [Values.FL_torque_engine, Values.FR_torque_engine, Values.RL_torque_engine, Values.RR_torque_engine]
	for i in range(4):
		if driven_wheels[i] == true:
			angular_velocity_sum += WheelData.wheel_angular_velocity[i]
			driven_count += 1
	
	# engine torque calculation
	
	var normalized_rpm = EngineData.engine_rpm / Values.max_rpm
	var engine_torque: float

	engine_torque = torque_curve.sample(normalized_rpm) * Values.max_torque * throttle_input

	if TransmissionData.is_shifting:
		clutch_engagement = 0.0
	
	# engine friciton calculation
	
	var base_friction = Values.friction_c0                      
	var linear_friction = Values.friction_c1 * normalized_rpm       
	var quadratic_friction = Values.friction_c2 * normalized_rpm * normalized_rpm
	var engine_friction = base_friction + linear_friction + quadratic_friction
	
	# clutch torque calculation
			
	if driven_count > 0:
		target_engine_ang_vel = (angular_velocity_sum / driven_count) * drivetrain_ratio
		var speed_difference = EngineData.engine_angular_velocity - target_engine_ang_vel
		var max_transferable_torque = Values.max_clutch_torque * clutch_engagement
					
		if abs(speed_difference) > Values.unlock_threshold:
			EngineData.clutch_torque_on_engine = -sign(speed_difference) * max_transferable_torque
		else:
			var required_torque = (Values.engine_inertia * (target_engine_ang_vel - EngineData.engine_angular_velocity)) / delta
			
			if abs(required_torque) <= max_transferable_torque:
				EngineData.engine_angular_velocity = target_engine_ang_vel
				EngineData.clutch_torque_on_engine = 0.0
			else:
				EngineData.clutch_torque_on_engine = -sign(speed_difference) * max_transferable_torque
			
	# engine rpm calculation
			
	var net_engine_torque = engine_torque - engine_friction + EngineData.clutch_torque_on_engine
	var engine_angular_accel = net_engine_torque / Values.engine_inertia
	EngineData.engine_angular_velocity += engine_angular_accel * delta
	EngineData.engine_angular_velocity = clamp(EngineData.engine_angular_velocity, Values.stall_rpm * TAU / 60.0, Values.max_rpm * TAU / 60.0)
	EngineData.engine_rpm = EngineData.engine_angular_velocity * 60.0 / TAU
	
	# engine stalling
	
	if EngineData.engine_rpm <= Values.stall_rpm + 50.0 and clutch_engagement > 0.1 and not EngineData.engine_stalled:
		EngineData.engine_stalled = true
		
	if EngineData.engine_stalled:
		engine_torque = 0.0
		clutch_engagement = 0.0
		EngineData.engine_angular_velocity = 0.0
		
	if Input.is_action_pressed("Ignition"):
		EngineData.engine_stalled = false
		EngineData.engine_angular_velocity = Values.idle_rpm * TAU / 60.0
		
	
	# Torque division (lsds, open diff)
	
	var front_axle = [0,1]
	var rear_axle = [2,3]
	var driven_axle = []
	
	var clutch_torque_to_wheels = -EngineData.clutch_torque_on_engine 
	var torque_at_wheels = clutch_torque_to_wheels * (drivetrain_ratio) * Values.drive_train_efficeny
	
	# finding axle usage
	
	if Values.FL_torque_engine and Values.FR_torque_engine and Values.RL_torque_engine and Values.RR_torque_engine:
		driven_axle =[front_axle, rear_axle]
	elif Values.FL_torque_engine and Values.FR_torque_engine:
		driven_axle = [front_axle]
	elif Values.RL_torque_engine and Values.RR_torque_engine:
		driven_axle = [rear_axle]
	else:
		var per_wheel_torque = torque_at_wheels / EngineData.driven_count if EngineData.driven_count > 0 else 0.0
		for i in range(4):
			if EngineData.driven_wheels[i]:
				EngineData.wheel_engine_torque[i] = per_wheel_torque
			else:
				EngineData.wheel_engine_torque[i] = 0.0
	
	for axle in driven_axle:
		
		# awd behavior
		
		var axle_torque: float
		if driven_axle.size() == 2:
			axle_torque = torque_at_wheels * Values.center_diff_split if axle == front_axle else torque_at_wheels * (1.0 - Values.center_diff_split)
		else:
			axle_torque = torque_at_wheels
		
		var slip_a = WheelData.longitude_force[axle[0]]
		var slip_b = WheelData.longitude_force[axle[1]]
		
		var T_lock: float
		var T_high: float
		var T_low: float
		
		# type of lsd or open diff
		
		if Values.torsen_lsd:
			if min(slip_a, slip_b) <= 0.0:
				T_high = axle_torque / 2.0
				T_low  = axle_torque / 2.0
			else:
				T_high = axle_torque * (Values.TBR / (Values.TBR + 1.0))
				T_low  = axle_torque * (1.0 / (Values.TBR + 1.0))
		elif Values.clutch_lsd:
			T_lock = Values.minimum_clutch_lsd_force + (axle_torque * Values.clutch_lsd_ramp_factor)
			T_lock = min(T_lock, axle_torque / 2.0) 
			T_high = (axle_torque / 2.0) + T_lock
			T_low  = (axle_torque / 2.0) - T_lock
		elif Values.electronic_lsd:
			pass # will write logic
		elif Values.open_diff:
			T_high = axle_torque / 2.0
			T_low  = axle_torque / 2.0
		
		# actual torque division
		
		if (slip_a - slip_b) > Values.SLIP_THRESHOLD:
			EngineData.wheel_engine_torque[axle[0]] = T_low
			EngineData.wheel_engine_torque[axle[1]] = T_high
		elif (slip_b - slip_a) > Values.SLIP_THRESHOLD:
			EngineData.wheel_engine_torque[axle[0]] = T_high
			EngineData.wheel_engine_torque[axle[1]] = T_low
		else:
			EngineData.wheel_engine_torque[axle[0]] = axle_torque / 2.0
			EngineData.wheel_engine_torque[axle[1]] = axle_torque / 2.0
