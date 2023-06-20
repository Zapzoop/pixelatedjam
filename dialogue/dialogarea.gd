extends Area2D

export var text_key = "" #set the key here
var area_active = false


func _input(event):
	if area_active and event.is_action_pressed("action"):
		print("Emitted")
		Signalbus.emit_signal("display_dialog", text_key)


func _on_dialoguearea_area_entered(area):
	area_active = true

func _on_dialoguearea_area_exited(area):
	area_active = false
