extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := DelegateEffect.new()
	effect.execute(targets)
