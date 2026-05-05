extends Card


func apply_effects(targets: Array[Node]) -> void:
	var redeem_effect := PersonificationEffect.new()
	redeem_effect.execute(targets)
