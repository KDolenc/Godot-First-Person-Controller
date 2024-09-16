class_name State
extends Node

@onready var state_machine = get_parent()
@onready var player : Player = state_machine.get_parent()

@warning_ignore("unused_signal")
signal transition(new_state_name: StringName)

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	pass
