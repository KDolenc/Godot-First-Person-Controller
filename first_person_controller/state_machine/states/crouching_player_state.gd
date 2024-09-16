class_name CrouchingPlayerState
extends State

func enter() -> void:
	player.speed = player.crouch_walk_speed
	player.animation_player.play("crouch")

func exit() -> void:
	player.animation_player.play_backwards("crouch")

func physics_update(delta: float) -> void:
	player.update_movement(delta)

func update(delta: float) -> void:
	player.update_bob(delta)
	
	# Unable to uncrouch if there is a surface above the player.
	if player.uncrouch_shape_cast.is_colliding():
		return
	
	# Transition to FallingState if the player has fallen off a ledge.
	if player.velocity.y <= 0.0 and !player.is_on_floor():
		transition.emit("FallingPlayerState")
	
	# Transition to either IdleState or WalkingState if no crouch input detected.
	elif !Input.is_action_pressed("crouch"):
		if player.velocity.length() <= 0.1:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	
	# Transition to JumpState if jump input detected.
	elif Input.is_action_pressed("jump"):
		transition.emit("JumpingPlayerState")
