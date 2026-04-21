class_name CarValues
extends Resource


	#######
	# CAR #
	#######
@export_group("Car")
@export var wheel_base = 2.3
@export var track = 1.5

	########################
	# SUSPENSION VARIABLES #
	########################

@export_group("Suspension")
@export var rest_length = [0.18, 0.18, 0.18, 0.18]
@export var spring_stiffness = [28700.0, 28700.0, 17000.0, 17000.0]
@export var max_compression = [0.085, 0.085, 0.090, 0.090]
@export var wheel_spring_force = [Vector3(), Vector3(), Vector3(), Vector3()]
@export var weight_distribution = [0.25, 0.25, 0.25, 0.25]
@export var velocity_exponent = 1.0
@export var rear_antiroll_bar = true
@export var front_antiroll_bar = true
@export var rear_antiroll_bar_stiffness = 2870.0
@export var front_antiroll_bar_stiffness = 1700.0

	######################
	# STEERING VARIABLES #
	######################
	
@export_group("Steering")
@export var max_tire_turn_angle = 900.0
@export var steering_ratio = 15.0
@export var tire_turn_speed = 3.0
@export var steering_stiffness = 20000

	###################
	# BRAKE VARIABLES #
	###################
	
@export_group("Brake")
@export var max_brake_torque = 41.0


@export_group("Assists")

@export_subgroup("ABS")
@export var ABS = false
@export var ABS_Rate: float
@export var abs_slip_threshold = -0.15
@export var abs_decay_rate = -25.0

@export_subgroup("TC")
@export var TC = false
@export var tc_slip_threshold = 0.12 
@export var tc_decay_rate = -20.0     

@export_subgroup("Stability")
var Stability = false

	####################
	# ENGINE VARIABLES #
	####################

@export_group("Motor")
@export var max_torque = 351.0
@export var max_rpm = 7000.0
@export var idle_rpm = 700.0
@export var stall_rpm = 500.0
@export var engine_inertia = 0.75
@export var FL_torque_engine = false
@export var FR_torque_engine = false
@export var RL_torque_engine = true
@export var RR_torque_engine = true
@export var FR_torque_brake = true
@export var FL_torque_brake = true
@export var RR_torque_brake = true
@export var RL_torque_brake = true
@export var friction_c0 = 15.0
@export var friction_c1 = 20.0
@export var friction_c2 = 25.0

	#################
	# LSD VARIABLES #
	#################
	
@export_subgroup("Limited Slip Differential")
# lsd does not apply to abnormal drivetrain configurations (Example: Front Right, Left Back Wheel drive)

@export var torsen_lsd = false
@export var clutch_lsd = false
@export var electronic_lsd = false
@export var open_diff = true
@export var minimum_clutch_lsd_force = 100.0
@export var clutch_lsd_ramp_factor = 1.0
@export var center_diff_split = 0.5 # front bias
@export var TBR = 2.0
@export var SLIP_THRESHOLD = 0.01

	##########################
	# TRANSMISSION VARIABLES #
	##########################

@export_group("Transmission")
@export var is_shifting = false
@export var shift_timer = 0.0
@export var drive_train_efficeny = 0.86
@export var final_drive = 4.3
@export var gear_ratio = [-3.968, 0.0, 3.136, 1.888, 1.330, 1.0, 0.814]
@export var current_gear = 1
@export var max_clutch_torque = 340.0
@export var unlock_threshold = 12.0


	###################
	# WHEEL VARIABLES #
	###################

@export_group("Wheel")
@export var wheel_radius = 0.3
@export var wheel_mass = 15.0
@export var rolling_resistance_coeff = 0.013
@export var friction_coefficient = 1.1
@export var camber_angles = [-1.2, -1.2, -1.7, -1.7]
@export var camber_gain = [-18.0, -18.0, -33.0, -33.0]

@export_subgroup("Pacejka Longitudinal")
@export var b0 = 1.5
@export var b1 = -8.0
@export var b2 = 1100.0
@export var b3 = 0.0
@export var b4 = 300.0
@export var b5 = 0.0
@export var b6 = 0.0
@export var b7 = 0.0
@export var b8 = -2.0
@export var b9 = 0.0
@export var b10 = 0.0
@export var b11 = 0.0
@export var b12 = 0.0
@export var b13 = 0.0

@export_subgroup("Pacejka Lateral")
@export var a0 = 1.75
@export var a1 = -10.0
@export var a2 = 1000.0
@export var a3 = 800.0
@export var a4 = 10.0
@export var a5 = 0.0
@export var a6 = -0.08
@export var a7 = -2.0
@export var a8 = 0.0
@export var a9 = 0.0
@export var a10 = 0.0
@export var a11 = 0.0
@export var a12 = 0.0
@export var a13 = 0.0
@export var a14 = 0.0
@export var a15 = 0.0
@export var a16 = 0.0
@export var a17 = 0.0

@export_subgroup("Aligning Torque")
@export var Ro: float = 0.287     
@export var FNzo: float = 2.7       
@export var ssz1: float = 0.0
@export var ssz2: float = 0.05
@export var ssz3: float = 0.0
@export var ssz4: float = 0.0
@export var lambda_s: float = 1.0
@export var Br: float = 4.0
@export var Cr: float = 1.0
@export var Dr: float = 0.05
@export var Bt: float = 9.0
@export var Ct: float = 1.05
@export var Dt: float = 0.035
@export var Et: float = -1.2

@export_subgroup("Pacejka Longitudinal G-Function")
@export var rBx1 = 5.0
@export var rBx2 = 8.0
@export var rBx3 = 0.0
@export var rCx1 = 1.05
@export var rEx1 = -0.2
@export var rEx2 = 0.0
@export var rHx1 = 0.0
@export var lambda_xalpha = 1.0

@export_subgroup("Pacejka Lateral G-Function")
@export var rBy1 = 7.0
@export var rBy2 = 2.5
@export var rBy3 = 0.0
@export var rBy4 = 0.0
@export var rCy1 = 1.0
@export var rEy1 = -0.2
@export var rEy2 = 0.0
@export var rHy1 = 0.0
@export var rHy2 = 0.0
@export var rVy1 = 0.0
@export var rVy2 = 0.0
@export var rVy3 = 0.0
@export var rVy4 = 4.0
@export var rVy5 = 1.9
@export var rVy6 = 10.0
@export var lambda_ykappa = 1.0
@export var lambda_Vyk = 1.0
