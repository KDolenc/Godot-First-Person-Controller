class_name StateMachine
extends Node

@onready var player : Player = get_parent()

@export var current_state : State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_state_transition)
		else:
			push_warning(child.name, " is not class_name: State.")
	
	current_state.enter()

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)

func _process(delta: float) -> void:
	current_state.update(delta)

func on_state_transition(new_state_name: StringName) -> void:
	if states.get(new_state_name) == null:
		push_error(new_state_name, " is not a valid State.")
	
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != current_state:
			current_state.exit()
			new_state.enter()
			current_state = new_state
