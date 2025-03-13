class_name Player extends CharacterBody3D


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

var dir_input = Vector2.ZERO

@export_range(0,100) var push_speed = 1.0

## The directional force that is applied to the player every frame in the input direction while on the floor
@export_range(0,100) var floor_speed = 50.0
## Drag is applied as an equal opposite force to the player's velocity
@export_range(0,40) var floor_drag = 10.0
## The directional force that is applied to the player every frame in the input direction
@export_range(0,100) var air_speed = 50.0
## Drag is applied as an equal opposite force to the player's velocity
@export_range(0,.2) var air_drag = 0.0
## Not yet implemented
@export var max_speed = 100

@export_range(0,.5) var coyote_time = .15

## The vertical impulse force that is applied upon entering the jump state.
@export_range(0,50) var jump_speed = 10.0
## Gravity while in the jump state.
@export_range(0,50) var jump_gravity: float = 9.8
## Gravity after jump is released and before Y velocity reaches 0.
@export_range(0,100) var end_jump_gravity: float = 40
## Base gravity while in the fall state.
@export_range(0,50) var fall_gravity: float = 20


func _process(delta: float) -> void:
	if GameState.input_state == GameState.InputStates.CONTROLLER: 
		controller_update()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("push"):
		push(Vector3.ZERO, push_speed)
	elif Input.is_action_pressed("pull"):
		pull(Vector3.ZERO, push_speed)
	if is_on_floor():
		move(delta,floor_speed,floor_drag)
	else:
		move(delta,air_speed,air_drag)
		do_gravity(delta)

#region getting input
func _input(event):
	if event is InputEventMouse:
		mouse_update(event)
	elif event.is_action_pressed("jump"):
		jump()
	elif event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func mouse_update(event: InputEventMouse):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotate(event.relative.x, event.relative.y, MOUSE_LOOK_SPEED)

func control(delta):
	#get player input vector, normalized
	dir_input = Input.get_vector("left","right","forward","back").normalized()

func controller_update():
	var controller_input = Input.get_vector("look left","look right","look up","look down")
	if controller_input != Vector2.ZERO:
		camera_rotate(controller_input.x,controller_input.y, CONTROLLER_LOOK_SPEED)
#endregion

#region camera

func camera_rotate(relative_x: float, relative_y: float,look_speed):
		# modify accumulated mouse rotation
		rot_x -= relative_x * look_speed * x_sensitivity * global_sensitivity
		rot_y -= relative_y * look_speed * y_sensitivity * global_sensitivity
		rot_y = clamp(rot_y,Y_LOOK_MIN,Y_LOOK_MAX)
		
		transform.basis = Basis() # reset rotation
		camera.transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		camera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
#endregion

#region basic movement code

func move(delta: float,move_speed: float = floor_speed,drag: float = floor_drag):
	control(delta)
	add_local_velocity(Vector3(dir_input.x,0,dir_input.y) * delta * move_speed)
	do_drag(delta, drag)
	move_and_slide()

func do_drag(delta: float, move_drag: float = floor_drag):
	velocity.x += -velocity.x * move_drag * delta
	velocity.z += -velocity.z * move_drag * delta

func do_gravity(delta: float,grav: float = jump_gravity):
	velocity.y -= grav * delta

func jump(jump_spd: float = jump_speed):
	velocity.y = jump_spd

## Returns velocity in relation to the camera
func get_local_velocity() -> Vector3:
	return velocity.rotated(Vector3.UP, -rot_x)

## Sets velocity in relation to the camera
func set_local_velocity(new_vel: Vector3) -> void:
	velocity = new_vel.rotated(Vector3.UP, rot_x)

## Adds velocity in relation to the camera
func add_local_velocity(new_vel: Vector3) -> void:
	velocity += new_vel.rotated(Vector3.UP, rot_x)
#endregion

#region pushing pulling

func pull(anchor_point: Vector3 = Vector3.ZERO, magnitude: float = 1):
	var direction = anchor_point - position
	velocity += direction.normalized() * magnitude
	print("pulling in direction: %s" % direction)

func push(anchor_point: Vector3 = Vector3.ZERO, magnitude: float = 1):
	pull(anchor_point,-magnitude)

#endregion
