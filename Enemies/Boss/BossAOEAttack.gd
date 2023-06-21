extends Area2D

var damage: int = 1
onready var sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play()
	
	yield(sprite, "animation_finished")
	queue_free()

func _on_sprite_frame_changed() -> void:
	var hitbox_active = sprite.frame >= 3 && sprite.frame <= 6
	
	monitoring = hitbox_active
	monitorable = hitbox_active
