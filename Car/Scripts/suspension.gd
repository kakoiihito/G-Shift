extends Node

func suspension_proccess(ray: RayCast3D, Data: RuntimeData.suspension, car: RigidBody3D, Values: Resource):
	var arb_force = [0.0, 0.0, 0.0, 0.0]
	var wheel_index = ray.get_meta("wheel_index")
	var wheels = [car.fl_wheel_mesh, car.fr_wheel_mesh, car.rl_wheel_mesh, car.rr_wheel_mesh]
	
	if ray.is_colliding():
		
		# compression calc
		
		var hit = ray.get_collision_point()
		var up_dir_spring = ray.global_transform.basis.y
		var hit_distance = ray.global_position.distance_to(hit)
		Data.compression[wheel_index] = clamp(Values.rest_length[wheel_index] - hit_distance, 0.0, Values.max_compression[wheel_index]) 
			
		# anti roll bar calc
			
		if Values.front_antiroll_bar == true:
			var arb = Values.front_antiroll_bar_stiffness * (Data.compression[0] - Data.compression[1])
			
			arb_force[0]  += -arb
			arb_force[1] +=  arb
			
		if Values.rear_antiroll_bar == true:
			var arb = Values.rear_antiroll_bar_stiffness * (Data.compression[2] - Data.compression[3])

			arb_force[2]  += -arb
			arb_force[3] +=  arb

		# spring dampning calc

		var damper_ratio = 0.7
		var world_vel = _get_point_velocity(hit, car)
		var relative_vel = up_dir_spring.dot(world_vel)
		var sprung_mass = car.mass * Values.weight_distribution[wheel_index]
		var c_crit = 2.0 * sqrt(Values.spring_stiffness[wheel_index] * sprung_mass)
		var c = damper_ratio * c_crit
		var spring_dampning = c * pow(abs(relative_vel), Values.velocity_exponent) * sign(relative_vel)
		
		# spring force calc
		
		var spring_force = Values.spring_stiffness[wheel_index] * Data.compression[wheel_index]
		var wheel_force_area = ray.global_position - car.global_position
		Data.wheel_spring_force[wheel_index] = (spring_force - spring_dampning + arb_force[wheel_index]) * up_dir_spring

		wheels[wheel_index].position.y = -Data.compression[wheel_index] # visual of suspension compression and rarefaction
		car.apply_force(Data.wheel_spring_force[wheel_index], wheel_force_area) # application
	else:
		Data.compression[wheel_index] = 0.0
		wheels[wheel_index].position.y = 0.0
		
	
func _get_point_velocity(point: Vector3, car: RigidBody3D) -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(point - car.global_position)
