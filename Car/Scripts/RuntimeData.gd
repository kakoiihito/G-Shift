extends Node

# used for real time calculation, do not mess with these variables unless you know what your doing


var wheel_spring_force = [Vector3(), Vector3(), Vector3(), Vector3()]
var compression = [0.0, 0.0, 0.0, 0.0]

var wheel_brake_torque = [0.0, 0.0, 0.0, 0.0]
var abs_active = [false, false, false, false]
var active_wheels_brake: int

var wheel_engine_torque = [0.0, 0.0, 0.0, 0.0]

var is_shifting = false
var current_gear_ratio: float
var shift_timer = 0.0
var current_gear = 1

var wheel_angular_velocity = [0.0, 0.0, 0.0, 0.0]
var F_max = [0.0, 0.0, 0.0, 0.0]
var longitude_force = [0.0, 0.0, 0.0, 0.0]
var lateral_force = [0.0, 0.0, 0.0, 0.0]
var slip_ratio = [0.0, 0.0, 0.0, 0.0]
var aligning_torque = [0.0, 0.0, 0.0, 0.0]
