class_name Player
extends CharacterBody3D

@export_group("Components")
@export var collision_shape : CollisionShape3D
@export var camera : Camera3D
@export var uncrouch_shape_cast : ShapeCast3D
@export var animation_player: AnimationPlayer
@export var state_machine : StateMachine

@export_group("Movement")
var speed : float = 0.0
var is_crouching : bool = false
@export var acceleration : float = 8.0
@export var walk_speed : float = 5.0
@export var run_speed : float = 7.0
@export var crouch_walk_speed : float = 3.0
@export var crouch_speed : float = 8.0
@export var jump_force : float = 6.5
@export var air_control : float = 2.0

@export_group("Head Bob")
var headbob : Vector2 = Vector2.ZERO
@export var headbob_on : bool = true
@export var headbob_frequency : float = 4.0
@export var headbob_amplitude : float = 0.05

@export_group("Settings")
@export var mouse_sensitivity : float = 0.001
@export var joypad_sensitivity : float = 2.5
@export var joypad_deadzone : float = 0.2
@export var fov : float = 90.0
@export var max_fov : float = 100.0

var camera_height : float = 0.0

var input_direction : Vector2 = Vector2.ZERO
var joypad_axis : Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera.fov = fov
	camera_height = camera.position.y
	
	uncrouch_shape_cast.shape.radius = collision_shape.shape.radius - 0.01

# Handles Keyboard and Joypad input.
func _input(event: InputEvent) -> void:
	# Handle Keyboard movement input.
	if event is InputEventKey:
		var new_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if new_input_direction.x > 0.5:
			new_input_direction.x = 1.0
		elif new_input_direction.x < -0.5:
			new_input_direction.x = -1.0
		else:
			new_input_direction.x = 0.0
		
		if new_input_direction.y > 0.5:
			new_input_direction.y = 1.0
		elif new_input_direction.y < -0.5:
			new_input_direction.y = -1.0
		else:
			new_input_direction.y = 0.0
		input_direction = new_input_direction
	
	# Handle Joypad movement input.
	if event is InputEventJoypadMotion:
		input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Handle Joypad look input.
	if event is InputEventJoypadMotion:
		if event.axis == 3:
			if abs(event.axis_value) > joypad_deadzone:
				joypad_axis.y = -event.axis_value
			else:
				joypad_axis.y = 0.0
		elif event.axis == 2:
			if abs(event.axis_value) > joypad_deadzone:
				joypad_axis.x = -event.axis_value
			else:
				joypad_axis.x = 0.0

# Handles mouse movement.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Updates player movement.
func _physics_process(_delta: float) -> void:
	move_and_slide()

# Updates everything else.
func _process(delta: float) -> void:
	handle_joypad_input(delta)
	update_fov(delta)

# Handles joypad input (Only for looking, walking is still captured along with keystrokes).
# Input is recieved in _unhandled_input() and stored in joypad_axis.
func handle_joypad_input(delta: float) -> void:
	camera.rotate_x(joypad_axis.y * joypad_sensitivity * delta)
	rotate_y(joypad_axis.x * joypad_sensitivity * delta)

# Handles player movement.
func update_movement(delta: float) -> void:
	var direction := (transform.basis * Vector3(input_direction.x, 0.0, input_direction.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, acceleration * 2.0 * delta) # Twice as quick to decelerate
			velocity.z = lerp(velocity.z, 0.0, acceleration * 2.0 * delta) # Twice as quick to decelerate
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, air_control * delta)

# Causes the camera to bob up-down and left-right.
func update_bob(delta: float) -> void:
	if headbob_on == true:
		headbob.y += velocity.length() * float(is_on_floor()) * delta
		headbob.x += velocity.length() * float(is_on_floor()) * delta
		var pos : Vector3 = Vector3.ZERO
		pos.y = sin(headbob.y * headbob_frequency) * headbob_amplitude + camera_height # Camera will default to y=0 if we don't add the camera_height
		pos.x = sin(headbob.x * headbob_frequency / 2.0) * headbob_amplitude
		camera.position = pos

# Centers the camera to a neutral position when the player has stopped moving.
func reset_bob(delta: float) -> void:
	headbob = Vector2.ZERO
	
	var pos : Vector3 = Vector3.ZERO
	pos.y = lerp(camera.position.y, camera_height, headbob_frequency * delta)
	pos.x = lerp(camera.position.x, 0.0, headbob_frequency * delta)
	
	camera.position = pos

# Changes the camera FOV when the player is running.
func update_fov(delta: float) -> void:
	var horizontal_velocity : Vector3 = velocity
	horizontal_velocity.y = 0.0
	
	var target_fov : float = clamp(horizontal_velocity.length() / walk_speed * fov, fov, max_fov)
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta) # 8.0 is a magic number that represents the quick change in FOV.

# Adds gravity to the player's y position.
func update_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * 2.0 * delta # Gravity feels slow without multiplying by 2.
