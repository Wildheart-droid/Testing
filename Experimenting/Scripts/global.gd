extends Node

var current_checkpoint : Checkpoint


var player_alive : bool
var playerBody :CharacterBody2D
var playerDamageZone : Area2D
var playerDamageAmount : int
var is_dashing : bool

var batDamageZone : Area2D
var batDamageAmount : int


func respawn_player():
	if current_checkpoint != null:
		playerBody.position = current_checkpoint.global_position
	else:
		#placeholder. will expand when more levels get made
		playerBody.position = Vector2(290,176)
