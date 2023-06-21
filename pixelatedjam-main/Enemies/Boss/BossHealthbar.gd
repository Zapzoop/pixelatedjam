extends ProgressBar

export var path_stats: NodePath
onready var stats = get_node(path_stats)

func _ready() -> void:
	max_value = stats.max_health
	value = stats.health
	
	stats.connect("health_changed", self, "_on_health_changed")

func _on_health_changed(new_health: float) -> void:
	value = new_health
