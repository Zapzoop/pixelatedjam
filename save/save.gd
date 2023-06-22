extends StaticBody2D

enum NamedEnum {SAVE, REGEN, Null}
export(NamedEnum) var State

var unique_id 


func _ready():
	get_state()
	unique_id = self.get_instance_id()
	$Particles2D.visible = false
	$Particles2D2.visible = false

func get_state():
	match State:
		0:
			make_save()
		1:
			make_regen()
			

func make_save():
	$Particles2D.visible = false
	$Particles2D2.visible = true

func make_regen():
	$Particles2D.visible = true
	
func disable():
	$Particles2D.visible = false
	$Sprite2.visible = false
	State = NamedEnum.Null
	
func _input(event):
	if event.is_action_pressed("action") and State == 1 and $dialoguearea.area_active==true and $dialoguearea.player.regen_booth == unique_id:
		if PlayerStats.health != 4:
			PlayerStats.health += 1
			disable()

func _on_dialoguearea_area_entered_save(area):
	Signalbus.emit_signal("myid", unique_id)

func _on_dialoguearea_area_exited_save(area):
	Signalbus.emit_signal("clearid")
