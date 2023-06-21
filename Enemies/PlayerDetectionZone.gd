extends Area2D

var player = null
var interacted = false

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	if interacted == false and get_parent().name == "Boss":
		Signalbus.emit_signal("bossencounter")
		Signalbus.emit_signal("display_dialog", "King")
		interacted = true
		#Signalbus.emit_signal("bossencounter")
	player = body

func _on_PlayerDetectionZone_body_exited(_body):
	player = null
