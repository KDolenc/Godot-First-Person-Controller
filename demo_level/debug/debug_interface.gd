extends Control

@export var player : Player
@export var label : Label

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("debug"):
			if visible:
				visible = false
			else:
				visible = true

func _process(delta: float) -> void:
	var debug_text : String = ""
	
	debug_text += str("FPS: ", int(1 / delta), "\n")
	debug_text += str("INPUT: ", Vector2(player.input_direction), "\n")
	debug_text += str("VELOCITY: ", player.velocity.length(), "\n")
	debug_text += str("STATE: ", player.state_machine.current_state.name, "\n")
	
	label.text = debug_text
