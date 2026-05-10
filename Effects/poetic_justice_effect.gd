class_name PoeticJusticeEffect
extends Effect

var amount := 5

func execute(targets: Array[Node]) -> void:
	var combat = Engine.get_main_loop().current_scene
	if not combat.get("_enemy_redeemed_this_round"):
		print("Poetic Justice: no redemption this round, no effect")
		return
	for target in targets:
		if not target:
			continue
		if target.get("stats") != null:
			target.stats.heal(amount)
			print("Poetic Justice: healed ", amount, " HP")
