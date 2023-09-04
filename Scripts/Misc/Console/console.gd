extends Control

# Dependencies
var inputLine


# Variables
var is_active : bool = false


func _ready():
	inputLine = get_node("InputLine")


func _process(delta):
	
	if is_active:
		visible = true
		inputLine.set_editable(true)
	else:
		visible = false
		inputLine.set_editable(false)
	



func _input(event):
	
	if Input.is_action_just_pressed("debug_toggle_console"):
		if is_active:
			is_active = false
		else:
			is_active = true
	
	if Input.is_action_just_pressed("ui_accept"):
		inputLine.clear()
		process_command(inputLine.text)

func process_command(command):
	print(command)
