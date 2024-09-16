class_name JumpingPlayerState
extends State

func enter() -> void:
	player.velocity.y = player.jump_force

func physics_update(delta: float) -> void:
	player.update_movement(delta)
	player.update_gravity(delta)

func update(delta: float) -> void:
	player.reset_bob(delta)
	
	# Transition to FallingState when the y velocity begins declining.
	if player.velocity.y < 0.0:
		transition.emit("FallingPlayerState")
	
	# Transition to either IdleState or WalkingState when the y velocity begins declinging AND the player is on the floor.
	elif player.velocity.y <= 0 and player.is_on_floor():
		if player.velocity.length() <= 0.1:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
