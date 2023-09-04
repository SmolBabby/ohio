extends KinematicBody
class_name Player

#Variables
var global = "root/global"
var control_lock : bool = false


const GRAVITY = -38.8
var vel = Vector3()
const MAX_SPEED = 16
const JUMP_SPEED = 16
const ACCEL = 6

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper
var fov 

var MOUSE_SENSITIVITY = 0.05

const CROUCH_HEIGHT = 2/3
var is_crouching = false

var collision_body
var flashlight

var is_typing : bool = false

func _ready():
	camera = $rotation_helper/Camera
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Flashlight
	collision_body = $collision_body
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	fov = get_viewport().get_camera().fov 

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):
	
	if control_lock:
		return
	
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_key_pressed(KEY_W):
		input_movement_vector.y += 1
	if Input.is_key_pressed(KEY_S):
		input_movement_vector.y -= 1
	if Input.is_key_pressed(KEY_A):
		input_movement_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_movement_vector.x += 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------
	
	# ----------------------------------
	# Jumping
	if is_on_floor() and !is_crouching:
		if Input.is_key_pressed(KEY_SPACE):
			vel.y = JUMP_SPEED
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	
	target *= MAX_SPEED
	
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if is_typing:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -80, 80)
		rotation_helper.rotation_degrees = camera_rot

# ----------------------------------
# Turning the flashlight on/off
	if Input.is_action_just_pressed("action_flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
# ----------------------------------

# ----------------------------------
# Crouch on/off
	if Input.is_action_just_pressed("move_crouch"):
		collision_body.scale.y = 1 * CROUCH_HEIGHT
	
	if Input.is_action_just_released("move_crouch"):
		collision_body.scale.y = 1
		transform.origin.y += 0.75
# ----------------------------------
	
	



func _on_Area_body_entered(body):
	if body is preload("res://Scripts/Misc/collectable.gd"):
		print("Item " + body.name + " collected")
		body.visible = false
		body.get_node("AudioPlayer").play(0)
		yield(body.get_node("AudioPlayer"), "finished") # waiting for the sfx to complete
		body.queue_free()

