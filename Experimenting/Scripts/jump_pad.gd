extends Node2D

@export var force = -400
var added_force = 1.3
@onready var animation_player = $AnimationPlayer
@onready var detection_area = $Area2D
var entered: Array

func _physics_process(delta):
	for area in detection_area.get_overlapping_areas():
		if not area in entered:
			_on_area_2d_area_entered(area)
	entered = detection_area.get_overlapping_areas()

func _on_area_2d_area_entered(area):
	if area.get_parent() is Player and area.get_parent().dead == false:
		animation_player.play("Boing")
		area.get_parent().jump_cut = false
		if area.get_parent().just_dashed:
			area.get_parent().can_dash = true
			area.get_parent().velocity.y = force * added_force
		else:
			area.get_parent().can_dash = true
			area.get_parent().velocity.y = force




