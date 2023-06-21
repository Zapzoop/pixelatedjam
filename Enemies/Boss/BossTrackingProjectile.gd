extends OwlProjectile

export var track_time = 3.0
var target: Node2D

func _ready() -> void:
	._ready()
	set_physics_process(false)
	
	var scale = self.scale
	self.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", scale, 0.25)

func _process(delta: float) -> void:
	if track_time > 0.33:
		_calculate_dir()
		rotation = atan2(dir.y, dir.x)
	
	track_time -= delta
	position += dir * -8.0 * delta
	
	if track_time > 0.0:
		return
	
	_activate()

func set_projectile_target(target: Node2D, position: Vector2) -> void:
	self.target = target
	
	_calculate_dir()
	self.position = position + dir * 0.5	

func _activate() -> void:
	set_process(false)
	set_physics_process(true)
	
	monitoring = true
	monitorable = true

func _calculate_dir() -> void:
	if !is_instance_valid(target):
		track_time = 0.0
		return
	
	var next_dir = global_position.direction_to(target.global_position)
	dir = dir.linear_interpolate(next_dir, 0.15)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	queue_free()
