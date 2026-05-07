class_name HardSetEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.get("stats") != null and target.stats.get("attack_modifier") != null:
			target.stats.attack_modifier += amount
			update_modifier_display(target)
			print("Attack modifier increased to: ", target.stats.attack_modifier)

func update_modifier_display(target: Node) -> void:
	if target.has_method("update_modifier"):
		target.update_modifier()
