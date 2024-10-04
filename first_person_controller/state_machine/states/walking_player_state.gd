class_name WalkingPlayerState
extends State

func enter() -> void:
	player.speed = player.walk_speed

func physics_update(delta: float) -> void:
	player.update_movement(delta)

func update(delta: float) -> void:
	player.update_bob(delta)
	
	# Transition to FallingState if player walked of a ledge.
	if !player.is_on_floor():
		transition.emit("FallingPlayerState")
	
	# Transition to IdleState if no movement input detected and the player is still.
	elif player.input_direction == Vector2.ZERO and player.velocity.length() <= 0.1:
		transition.emit("IdlePlayerState")
	
	# Transition to RunningState if run input detected, player is travelling faster that walk speed, player is not crouching, and player is not walking backwards.
	# Player only has to travel 90% of walk_speed. This is beacause the player never walks at exactly the walk_speed so an approximation is needed.
	# input_dir.y needs to be < 0.1, < 0.0 doesnt work. Makes the player unable to sprint while running sideways. NOT SURE WHY.
	elif Input.is_action_pressed("run") and player.velocity.length() > player.walk_speed * 0.90 and !player.is_crouching and player.input_direction.y < 0.1:
		transition.emit("RunningPlayerState")
	
	# Transition to JumpState if jump input detected.
	elif Input.is_action_pressed("jump"):
		transition.emit("JumpingPlayerState")
	
	# Transition to CrouchState if crouch input detected.
	elif Input.is_action_pressed("crouch"):
		transition.emit("CrouchingPlayerState")
