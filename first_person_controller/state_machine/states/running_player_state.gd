class_name RunningPlayerState
extends State

func enter() -> void:
	player.speed = player.run_speed

func exit() -> void:
	player.speed = player.walk_speed

func physics_update(delta: float) -> void:
	player.update_movement(delta)

func update(delta: float) -> void:
	player.update_bob(delta)
	
	# Transition to FallingState if player walked of a ledge.
	if !player.is_on_floor():
		transition.emit("FallingPlayerState")
	
	# Transition to WalkingState if no run input detected or if the player is travelling at walk speed.
	# Player has to fall to 90% of walk_speed. This is beacause the player enters the RunningState at walk speed so the state will change to walkign immediately.
	elif !Input.is_action_pressed("run") or player.velocity.length() < player.walk_speed * 0.9:
		transition.emit("WalkingPlayerState")
	
	# Transition to WalkState the imput changes to backwards movement.
	# This can be done by running straight, then left, then back, while maintaining velocity.
	elif player.input_direction.y > 0:
		transition.emit("WalkingPlayerState")
	
	
	# Transition to JumpState if jump input detected.
	elif Input.is_action_pressed("jump"):
		transition.emit("JumpingPlayerState")
	
	# Transition to CrouchState if crouch input detected.
	elif Input.is_action_pressed("crouch"):
		transition.emit("CrouchingPlayerState")
