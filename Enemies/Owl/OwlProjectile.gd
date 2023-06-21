class_name OwlProjectile
extends Area2D

export var damage: int = 1
export var speed: float = 250.0
export var lifetime: float = 1.0
export var randomise_speed = false
var dir: Vector2

func _ready() -> void:
	if randomise_speed:
		speed *= rand_range(0.85, 1.33)
	
	yield(get_tree(), "idle_frame")
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.start(lifetime)
	yield(timer, "timeout")
	
	queue_free()

func _physics_process(delta: float) -> void:
	position += dir * speed * delta

func set_projectile_position(position: Vector2, dir: Vector2) -> void:
	self.position = position + dir * 0.5
	self.dir = dir
