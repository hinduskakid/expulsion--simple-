extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := GlovesOffEffect.new()
	effect.execute(targets)
