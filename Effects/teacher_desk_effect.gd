class_name TeacherDeskShieldEffect
extends Effect

var amount := 3

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.get("stats") != null:
			target.stats.set_block(target.stats.block + amount)
			print("Teacher Desk Shield: gave ", amount, " block to ", target.name)
