extends StateNode

var player: Player

func _state_machine_ready() -> void:
	player = get_target()
