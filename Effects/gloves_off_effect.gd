class_name GlovesOffEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			var damage_amount: int = 0
			var party_members: Array = Engine.get_main_loop().current_scene.get_tree().get_nodes_in_group("player")
			var highest_modifier: int = 1
			for member in party_members:
				if member.get("stats") != null and member.stats.get("attack_modifier") != null:
					if member.stats.attack_modifier > highest_modifier:
						highest_modifier = member.stats.attack_modifier
			damage_amount = highest_modifier * 5
			target.take_damage(damage_amount)
			print("Gloves Off: dealt ", damage_amount, " damage")
