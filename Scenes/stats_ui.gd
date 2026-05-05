class_name StatsUI
extends HBoxContainer

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HBoxContainer = $Health
@onready var health_label: Label = %HealthLabel

var previous_health: int = -1 # tracks last known health to detect damage

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	health_label.text = str(stats.health)
	
	block.visible = stats.block > 0
	health.visible = stats.health > 0
	
	if previous_health != -1 and stats.health < previous_health: # health went down
		flash_damage()
	
	previous_health = stats.health # update tracked health

func flash_damage() -> void:
	var tween := create_tween()
	health_label.modulate = Color.RED # instantly go red
	tween.tween_property(health_label, "modulate", Color.WHITE, 1) # fade back to white over 0.4 seconds
