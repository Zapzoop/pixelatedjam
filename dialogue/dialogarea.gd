extends Area2D

export var text_key = "" #set the key here
var area_active = false

var player
var display_label

var air = preload("res://Allies/Air/Air.tscn")

func _ready():
	Signalbus.connect("finished",self,"onfinish")

func _input(event):
	if text_key == "Save":
		if area_active and event.is_action_pressed("action") and get_parent().State == 1:
			display_label.visible = false
		elif area_active and event.is_action_pressed("action") and get_parent().State == 0:
			display_label.visible = false
			Signalbus.emit_signal("display_dialog", text_key)
	elif area_active and event.is_action_pressed("action"):
		display_label.visible = false
		Signalbus.emit_signal("display_dialog", text_key)
		


func _on_dialoguearea_area_entered(area):
	display_label = area.get_child(1)
	player = area.get_parent()
	print(player)
	if not text_key in $"/root/SaveSystem".player["interacted"]:
		display_label.visible = true
		area_active = true

func _on_dialoguearea_area_exited(area):
	display_label.visible = false
	player = null
	display_label = null
	area_active = false

func onfinish():
	if text_key == "Ice" and player != null:
		player.set_global_position(Vector2(168,80))
	if text_key == "KingLose":
		load_air()

func load_air():
	var instance = air.instance()
	
	instance.set_global_position()
