extends Node


var weak_reference_force   = 1000.0
var strong_reference_force = 2800.0
var wheel_spring_force_prev: Array = [0.0, 0.0, 0.0, 0.0]

func _input_feedback(Data: RuntimeData.suspension):
	# FL=0, FR=1, RL=2, RR=3 (adjust indices to match your setup)
	var left_delta  = abs(Data.wheel_spring_force[0].length() - wheel_spring_force_prev[0]) \
					+ abs(Data.wheel_spring_force[2].length() - wheel_spring_force_prev[2])
	var right_delta = abs(Data.wheel_spring_force[1].length() - wheel_spring_force_prev[1]) \
					+ abs(Data.wheel_spring_force[3].length() - wheel_spring_force_prev[3])

	left_delta  /= 2.0
	right_delta /= 2.0

	for i in range(4):
		wheel_spring_force_prev[i] = Data.wheel_spring_force[i].length()



	# Left motor = left side, Right motor = right side
	var total = left_delta + right_delta
	if total > 0.001:  # deadzone to avoid noise when both are near zero
		var left_bias  = left_delta  / total  # 0.0 to 1.0
		var right_bias = right_delta / total

		var intensity = clamp(total / 2.0 / weak_reference_force, 0.0, 1.0)

		Input.start_joy_vibration(0, left_bias * intensity, right_bias * intensity, 0.1)
	else:
		Input.start_joy_vibration(0, 0, 0, 10)
