extends Control

@onready var info_label: Label = $VBoxContainer/HBoxContainer/Label
@export var car: Node3D
var car_velocity: float

func _process(_float) -> void:
	
	if car != null:
		# Speed
		car_velocity = car.linear_velocity.length()
		var speed = car_velocity * 2.237
		
		# Gear
		var gear = car.transmission.current_gear - 1
		
		# RPM
		var engine_rpm = car.engine.engine_rpm
		
		info_label.text = "%d MPH | %d RPM | %d Gear" % [int(speed), int(engine_rpm), int(gear)]
