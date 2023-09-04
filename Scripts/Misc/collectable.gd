extends KinematicBody
class_name Collectable

var animationPlayer

var vel = Vector3()

func _ready():
	animationPlayer = get_node("AnimationPlayer")
	animationPlayer.play("Hover")


func _process(delta):
	pass

func _physics_process(delta):
	
	if !is_on_floor():
		vel.y += (delta * -38)
	
	move_and_slide(vel)
