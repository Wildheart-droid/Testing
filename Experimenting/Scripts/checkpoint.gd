extends Node2D
class_name Checkpoint

@export var spawnpoint = false
@onready var animation_player = $AnimationPlayer
@onready var light = $PointLight2D

var activated = false

func activate():
	Global.current_checkpoint = self
	animation_player.play("Checkpoint_Activated")
	activated = true
	

func _on_area_2d_area_entered(area):
	if area.get_parent() is Player and !activated:
		activate()


func _on_animation_player_animation_finished(anim_name):
	animation_player.play("Checkpoint_In_Use")
