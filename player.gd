extends Node2D

const SPEED = 200

func _process(delta):
	if str(multiplayer.get_unique_id()) == name:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		position += input_vector.normalized() * SPEED * delta
		rpc("update_position", position)

@rpc("any_peer")
func update_position(new_pos):
	position = new_pos
