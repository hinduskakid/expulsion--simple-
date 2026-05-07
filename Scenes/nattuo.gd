class_name Nattuo
extends Area2D


@export var stats: CharacterStats : set = set_character_stats
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var modifier_label: Label = $ModifierLabel



var has_played := false


func set_character_stats(value: CharacterStats) -> void:
	stats = value.create_instance()
	if not  stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	update_player()

func update_player() -> void:
	if not stats is CharacterStats:
		return
	if not is_inside_tree():
		await ready
	sprite_2d.texture = stats.art
	update_stats()
	update_modifier()

func update_modifier() -> void:
	modifier_label.text = str(stats.attack_modifier)
	
func update_stats() -> void:
	stats_ui.update_stats(stats)
	

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	var unblocked: int = max(0, damage - stats.block)
	print("Nattuo take_damage: damage=", damage, " block=", stats.block, " unblocked=", unblocked)
	stats.take_damage(damage)
	if unblocked > 0:
		stats.attack_modifier = 1
		update_modifier()
		print("Modifier reset to 1, label text: ", modifier_label.text if modifier_label else "NULL LABEL")
	if stats.health <= 0:
		queue_free()

func _on_mouse_entered() -> void:
	if not has_played:
		modulate = Color.YELLOW


func _on_mouse_exited() -> void:
	if not has_played:
		modulate = Color.WHITE

func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if event.is_action_pressed("left_mouse"):
		print("Michla left clicked - emitting signal")
		Events.party_member_selected.emit(self)
