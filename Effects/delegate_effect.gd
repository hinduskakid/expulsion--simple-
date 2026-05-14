class_name DelegateEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.get("has_played") != null:
			target.has_played = false
			target.modulate = Color.WHITE
			Events.delegate_used.emit(target)
			print("Delegate: ", target.name, " can play again!")
