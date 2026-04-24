extends Card
func apply_effects(targets: Array[Node]) -> void:
	var block_effect := DeskShieldEffect.new()
	block_effect.amount = 5
	block_effect.execute(targets)
