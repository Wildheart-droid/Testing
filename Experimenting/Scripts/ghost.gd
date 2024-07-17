extends Sprite2D

func _ready():
	ghosting()
# Called when the node enters the scene tree for the first time.
func set_property(x_pos,y_pos,tx_scale):
	position.x = x_pos
	position.y = y_pos
	scale = tx_scale
	
func ghosting():
	if visible:
		var tween_fade = get_tree().create_tween()
		tween_fade.tween_property(self,"self_modulate",Color(1, 1, 1, 0),0.35)
		await tween_fade.finished
		queue_free()
