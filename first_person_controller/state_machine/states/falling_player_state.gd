class_name FallingState
extends State

func physics_update(delta: float) -> void:
	player.update_movement(delta)
	player.update_gravity(delta)

func update(delta: float) -> void:
	player.reset_bob(delta)
	
	# Transition to either IdleState or WalkingState if the player is on the floor.
	if player.is_on_floor() == true:
		var horizontal_velocity : Vector2 = Vector2(player.velocity.x, player.velocity.z)
		if horizontal_velocity.length() <= 0.1:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
