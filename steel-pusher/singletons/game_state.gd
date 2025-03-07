extends Node


enum InputStates {CONTROLLER,KBM}

var input_state = InputStates.KBM

func _input(event: InputEvent) -> void:
	if input_state == InputStates.CONTROLLER and (event is InputEventMouseButton or event is InputEventKey):
		input_state = InputStates.KBM
		print("Changed to Keyboard, button pressed: " + event.as_text())
	elif input_state == InputStates.KBM and (event is InputEventJoypadButton):
		input_state = InputStates.CONTROLLER
		print("Changed to Controller")
