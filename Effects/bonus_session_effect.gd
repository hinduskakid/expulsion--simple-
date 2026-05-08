class_name BonusSessionEffect
extends Effect

var amount := 15

func execute(targets: Array[Node]) -> void:
	var combat = Engine.get_main_loop().current_scene
	if not combat.get("_enemy_executed_this_round"):
		print("Bonus Session: no execution this round, no effect")
		return
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			target.take_damage(amount)
			print("Bonus Session: dealt ", amount, " damage")
