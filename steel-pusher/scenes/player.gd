extends CharacterBody3D


@onready var camera = get_viewport().get_camera_3d()

var x_sensitivity = 1
var y_sensitivity = 1
var global_sensitivity = 1
const MOUSE_LOOK_SPEED = .004
const CONTROLLER_LOOK_SPEED = .02

# accumulators
var rot_x = 0
var rot_y = 0
const Y_LOOK_MAX = PI/2
const Y_LOOK_MIN = -PI/2

func _process(delta: float) -> void:
	
	var controller_x_axis = Input.get_axis("look left","look right")
	var controller_y_axis = Input.get_axis("look up","look down")
	if controller_x_axis != 0 or controller_y_axis != 0:
		camera_rotate(controller_x_axis,controller_y_axis, CONTROLLER_LOOK_SPEED)

func _input(event):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotate(event.relative.x, event.relative.y, MOUSE_LOOK_SPEED)

func camera_rotate(relative_x: float, relative_y: float,look_speed):
		# modify accumulated mouse rotation
		rot_x -= relative_x * look_speed * x_sensitivity * global_sensitivity
		rot_y -= relative_y * look_speed * y_sensitivity * global_sensitivity
		rot_y = clamp(rot_y,Y_LOOK_MIN,Y_LOOK_MAX) 
		
		transform.basis = Basis() # reset rotation
		camera.transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		camera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
