extends Node2D

@onready var respawn_timer :Timer = $Respawn_Timer
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var detection_zone = $Area2D/CollisionShape2D
@onready var detection_area = $Area2D
var entered: Array

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	for area in detection_area.get_overlapping_areas():
		if not area in entered:
			_on_area_2d_area_entered(area)
	entered = detection_area.get_overlapping_areas()

func _on_area_2d_area_entered(area):
	if area.get_parent() is Player and area.get_parent().dead == false:
		if respawn_timer.time_left <= 0:
			if Global.is_dashing == true or area.get_parent().can_dash == false:
				sprite.visible = false
				detection_area.monitoring = false
				respawn_timer.start()
				area.get_parent().can_dash = true
				await respawn_timer.timeout
				sprite.visible = true
				detection_area.monitoring = true
				
		
