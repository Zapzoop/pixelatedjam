extends Area2D

export var text_key = "" #set the key here
var area_active = false

var display_label

func _input(event):
	if area_active and event.is_action_pressed("action"):
		display_label.visible = false
		Signalbus.emit_signal("display_dialog", text_key)


func _on_dialoguearea_area_entered(area):
	display_label = area.get_child(1)
	if not text_key in $"/root/SaveSystem".player["interacted"]:
		display_label.visible = true
		area_active = true

func _on_dialoguearea_area_exited(area):
	display_label.visible = false
	display_label = null
	area_active = false


