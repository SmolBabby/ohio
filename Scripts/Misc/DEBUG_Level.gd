extends Node


func _physics_process(delta):
	var children = self.get_children()
	for child in children:
		if child is KinematicBody:
			if child.transform.origin.y <= -50:
				child.transform.origin = Vector3(0, 50, 0)
