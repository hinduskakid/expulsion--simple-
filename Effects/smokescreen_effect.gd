class_name SmokescreenEffect
extends Effect

func execute(_targets: Array[Node]) -> void:
	var combat = Engine.get_main_loop().current_scene
	combat.enemy_turns_to_skip += 2
	print("Smokescreen: next 2 enemy turns will be skipped")
