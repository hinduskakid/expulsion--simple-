class_name Enemy
extends Area2D

const ARROW_OFFSET := 5

@export var stats: Stats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI

func set_enemy_stats(value: Stats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	update_enemy()

func update_stats() -> void:
	stats_ui.update_stats(stats)

func update_enemy() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
		
	sprite_2d.texture = stats.art
	arrow.position = Vector2(
	sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET,
	arrow.position.y  # keep whatever Y is set in the editor
)
	update_stats()
func take_damage(damage: int) -> void:
	if stats.is_downed:
		return  # no effect on downed enemies
	stats.take_damage(damage)
	if stats.health <= 0:
		go_down()

func go_down() -> void:
	stats.is_downed = true
	stats.downed_rounds_remaining = 3
	print("Enemy is downed!")
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "rotation_degrees", 90, 0.4)

func revive() -> void:
	stats.is_downed = false
	stats.health = stats.max_health / 2
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "rotation_degrees", 0, 0.4)
	stats.stats_changed.emit()
	print("Enemy revived with half HP!")

func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
