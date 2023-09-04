extends Monster

const ENEMIES = [Player]

var animationPlayer
onready var area = $DetectionArea


# Called when the node enters the scene tree for the first time.
func _ready():
	var animationPlayer = $AnimationPlayer
	animationPlayer.play("Idle")
	var anim = get_node("AnimationPlayer").get_animation("Idle")
	anim.set_loop(true)
	
	MAX_SPEED = 1000



func _physics_process(delta):
	detect(delta)
	animate()
	


func animate():
	if sqrt(pow(vel.x, 2) + pow(vel.z, 2)) < 1:
		print("A")
		animationPlayer.play("Idle")
		animationPlayer.set_speed_scale(2)
	else:
		print("B")
		animationPlayer.play("Run")
		animationPlayer.set_speed_scale(2 * (sqrt(pow(vel.x, 2) + pow(vel.z, 2)) / 20))
	

func detect(delta):
	var bodies = area.get_overlapping_bodies()
	var closest_body
	# If it detects someone
	if bodies.size() > 0 :
		
		# Look at closest
		for body in bodies:
			if body in ENEMIES:
				look_at(body.transform.origin, Vector3.UP)
				self.rotate_object_local(Vector3(0,1,0), 3.14)
				self.rotation_degrees.x = 0
				move(delta)



func move(delta):
	var global_direction = Vector3(0,0,1)
	
	var local_direction = global_direction.rotated(Vector3(0,1,0), rotation.y)
	
	hvel = local_direction * (debug_speed)
	
	if Input.is_action_just_pressed("debug_1"):
		debug_speed = MAX_SPEED
	
	vel = Vector3(hvel.x, vel.y + (delta * GRAVITY), hvel.z)
	
	vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
