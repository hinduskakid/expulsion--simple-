class_name PlotArmorEffect
extends Effect

var amount := 10

func execute(targets: Array[Node]) -> void:
	var combat = Engine.get_main_loop().current_scene
	if not combat.get("_enemy_redeemed_this_round"):
		print("Plot Armor: no redemption this round, no effect")
		return
	for target in targets:
		if not target:
			continue
		if target.get("stats") != null:
			target.stats.set_block(target.stats.block + amount)
			print("Plot Armor: gave ", amount, " block")
