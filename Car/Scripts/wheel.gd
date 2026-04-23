extends RayCast3D





func _get_point_velocity(point: Vector3, car: RigidBody3D) -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(point - car.global_position)
	
func _get_wheel_forces(ray: RayCast3D, WheelData: RuntimeData.wheels, SuspensionData: RuntimeData.suspension, car: RigidBody3D, Values: Resource):

	var wheel_index = ray.get_meta("wheel_index")
	
	WheelData.camber  =(Values.camber_angles[wheel_index]) + (Values.camber_gain[wheel_index] * SuspensionData.compression[wheel_index])
	var velocity_at_wheel = _get_point_velocity(ray.get_collision_point(), car)
	var side_dir = ray.global_transform.basis.x #
	var side_velocity = velocity_at_wheel.dot(side_dir)
	var forward_speed = velocity_at_wheel.dot(-ray.global_transform.basis.z)
	var wheel_surface_speed = WheelData.wheel_angular_velocity[wheel_index] * Values.wheel_radius
	var Fz = SuspensionData.wheel_spring_force[wheel_index].length() / 1000
		
	if ray.is_colliding():
		
		var safe_speed = max(abs(forward_speed), 0.1)
		
		WheelData.slip_angle[wheel_index] = -(atan2(side_velocity, safe_speed))
		
		WheelData.slip_ratio[wheel_index] = (wheel_surface_speed - forward_speed) / safe_speed
		var slip_ratio_percentage: float
		slip_ratio_percentage = clamp(WheelData.slip_ratio[wheel_index] * 100.0, -100.0, 100.0)

		var Fz_nominal_kN = (car.mass * 9.81) * Values.weight_distribution[wheel_index] / 1000.0  
		var dfz = (Fz - Fz_nominal_kN) / Fz_nominal_kN
		
		var D = Fz * (Values.b1 * Fz + Values.b2)
		var C = Values.b0
		var BCD = (Values.b3 * pow(Fz, 2) + Values.b4 * Fz) * exp(-Values.b5 * Fz)
		var B = BCD / (C * D)
		var H = Values.b9 * Fz + Values.b10
		var E = (Values.b6* pow(Fz, 2) + Values.b7 * Fz + Values.b8) *  (1 - Values.b13 * sign(slip_ratio_percentage+H))
		var V = Values.b11 * Fz + Values.b12
		var Bx1 = B * (slip_ratio_percentage + H)
		var Fxo = D * sin(C * atan(Bx1 - E * (Bx1 - atan(Bx1)))) + V

		var SHxa = Values.rHx1
		var alpha_s = WheelData.slip_angle[wheel_index] + SHxa
		var Bxa = (Values.rBx1 + Values.rBx3 * pow(WheelData.camber, 2)) * cos(atan(Values.rBx2 * slip_ratio_percentage)) * Values.lambda_xalpha
		var Cxa = Values.rCx1
		var Exa = Values.rEx1 + Values.rEx2 * dfz
		
		var Gxa0 = cos(Cxa * atan(Bxa * SHxa - Exa * (Bxa * SHxa - atan(Bxa * SHxa))))
		var Gxa = cos(Cxa * atan(Bxa * alpha_s - Exa * (Bxa * alpha_s - atan(Bxa * alpha_s)))) / Gxa0

		WheelData.longitude_force[wheel_index] = Gxa * Fxo
		
		var C1 = Values.a0
		var D1 = Fz * (Values.a1 * Fz + Values.a2) * (1 - Values.a15 * pow(WheelData.camber, 2))
		var BCD1 = Values.a3 * sin(atan(Fz / Values.a4) * 2) * (1 - Values.a5* abs(WheelData.camber))
		var B1 = BCD1 / (C1 * D1)
		var H1 = Values.a8 * Fz + Values.a9 + Values.a10 * WheelData.camber
		var E1 = (Values.a6 * Fz + Values.a7) * (1 - (Values.a16 * WheelData.camber + Values.a17) * sign(WheelData.slip_angle[wheel_index] + H1))
		var V1 = Values.a11 * Fz + Values.a12 + (Values.a13 * Fz + Values.a14) * WheelData.camber * Fz
		var Bx2 = B1 * (WheelData.slip_angle[wheel_index] + H1)
		var Fyo = D1 * sin(C1 * atan(Bx2 - E1 * (Bx2 - atan(Bx2)))) + V1

		var SHyk = Values.rHy1 + Values.rHy2 * dfz
		var kappa_s = slip_ratio_percentage + SHyk
		var Byk = (Values.rBy1 + Values.rBy4 * pow(WheelData.camber, 2)) * cos(atan(Values.rBy2 * (WheelData.slip_angle[wheel_index] - Values.rBy3))) * Values.lambda_ykappa
		var Cyk = Values.rCy1
		var Eyk = Values.rEy1 + Values.rEy2 * dfz
		var Gyk0 = cos(Cyk * atan(Byk * SHyk - Eyk * (Byk * SHyk - atan(Byk * SHyk))))
		var Gyk = cos(Cyk * atan(Byk * kappa_s - Eyk * (Byk * kappa_s - atan(Byk * kappa_s)))) / Gyk0

		var mu_y = D1 / Fz
		var DVyk = mu_y * Fz * (Values.rVy1 + Values.rVy2 * dfz + Values.rVy3 * WheelData.camber) * cos(atan(Values.rVy4 * WheelData.slip_angle[wheel_index]))
		var SVyk = DVyk * sin(Values.rVy5 * atan(Values.rVy6 * slip_ratio_percentage)) * Values.lambda_Vyk

		WheelData.lateral_force[wheel_index] = Gyk * Fyo + SVyk
		
		var stiffness_ratio_sq = pow(BCD/ BCD1, 2)
		var kappa_sq = pow(slip_ratio_percentage, 2)
		
		var alpha_t_eq = sqrt(WheelData.slip_angle[wheel_index] * WheelData.slip_angle[wheel_index] + stiffness_ratio_sq * kappa_sq) * sign(WheelData.slip_angle[wheel_index])
		var alpha_r_eq = sqrt(WheelData.slip_angle[wheel_index] * WheelData.slip_angle[wheel_index] + stiffness_ratio_sq * kappa_sq) * sign(WheelData.slip_angle[wheel_index])
		
		var s = Values.Ro * (Values.ssz1 + Values.ssz2 * (WheelData.lateral_force[wheel_index] / Fz_nominal_kN) + (Values.ssz3 + Values.ssz4 * dfz) * WheelData.camber) * Values.lambda_s
		
		var Mzr = Values.Dr * cos(Values.Cr * atan(Values.Br * alpha_r_eq))
		
		var trail = Values.Dt * cos(Values.Ct * atan(Values.Bt*alpha_t_eq - Values.Et * (Values.Bt*alpha_t_eq - atan(Values.Bt*alpha_t_eq)))) * cos(WheelData.slip_angle[wheel_index])

		var Mz_ = -trail * (WheelData.lateral_force[wheel_index] - SVyk)
		
		WheelData.aligning_torque[wheel_index] = (Mz_ + Mzr + s * WheelData.longitude_force[wheel_index]) * 1000.0
		
		var combined_force = (WheelData.longitude_force[wheel_index] * -ray.global_transform.basis.z) + (WheelData.lateral_force[wheel_index] * side_dir) # both vectors combined
		var force_pos = ray.get_collision_point() - car.global_position
		car.apply_force(combined_force , force_pos)

func _get_wheel_angular_velocity(ray: RayCast3D, delta: float, WheelData: RuntimeData.wheels, EngineData: RuntimeData.engine, BrakeData: RuntimeData.brake, SuspensionData: RuntimeData.suspension, car: RigidBody3D, Values: Resource):
	var wheel_inertia = 0.6 * Values.wheel_mass * Values.wheel_radius * Values.wheel_radius
	var wheel_index = ray.get_meta("wheel_index") 
	
	if not car.wheels[wheel_index].is_colliding():
		var air_drag_torque = 0.001 * WheelData.wheel_angular_velocity[wheel_index] * abs(WheelData.wheel_angular_velocity[wheel_index])
		var angular_decel = air_drag_torque / wheel_inertia
		WheelData.wheel_angular_velocity[wheel_index] -= angular_decel * delta
	else:
		var normal_force = SuspensionData.wheel_spring_force[wheel_index].length()
		var rolling_resistance = Values.rolling_resistance_coeff * normal_force * Values.wheel_radius * sign(WheelData.wheel_angular_velocity[wheel_index])
		
		if WheelData.wheel_angular_velocity[wheel_index] == 0.0:
			rolling_resistance = 0.0
			
		var ground_reaction_torque = -WheelData.longitude_force[wheel_index] * Values.wheel_radius
		var net_torque = EngineData.wheel_engine_torque[wheel_index] - BrakeData.wheel_brake_torque[wheel_index] + ground_reaction_torque - rolling_resistance
		
		var angular_acceleration = net_torque / wheel_inertia if wheel_inertia > 0 else 0
		
		var prev_sign = sign(WheelData.wheel_angular_velocity[wheel_index])
		WheelData.wheel_angular_velocity[wheel_index] += angular_acceleration * delta
		
		
		if BrakeData.wheel_brake_torque[wheel_index] > 0 and sign(WheelData.wheel_angular_velocity[wheel_index]) != prev_sign:
			WheelData.wheel_angular_velocity[wheel_index] = 0.0
			

		
		
		
			
