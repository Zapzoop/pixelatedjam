extends StaticBody2D

enum NamedEnum {SAVE, REGEN}
export(NamedEnum) var State
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_state()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_state():
	match State:
		0:
			make_save()
		1:
			print("regen")

func make_save():
	$Particles2D.visible = true
	$WorldEnvironment.get_environment().glow_enabled = true
	$Sprite2.visible = true
	
func _input(event):
	if event.is_action_pressed("action") and State == 1:
		print("good")
		if $dialoguearea.player.stats.health != 4:
			print("how we are here")
			$dialoguearea.player.stats.health += 1
