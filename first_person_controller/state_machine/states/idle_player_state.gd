class_name IdlePlayerState
extends State

func physics_update(delta: float) -> void:
	player.update_movement(delta)

func update(delta: float) -> void:
	player.reset_bob(delta)
	
	# Transition to FallingState if player walked of a ledge.
	if !player.is_on_floor():
		transition.emit("FallingPlayerState")
	
	# Transition to WalkState if movement input detected.
	elif player.input_direction:
		transition.emit("WalkingPlayerState")
	
	# Transition to JumpState if jump input detected.
	elif Input.is_action_pressed("jump"):
		transition.emit("JumpingPlayerState")
	
	# Transition to CrouchState if crouch input detected.
	elif Input.is_action_pressed("crouch"):
		transition.emit("CrouchingPlayerState")
