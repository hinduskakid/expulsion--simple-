extends Card

func apply_effects(targets: Array[Node]) -> void:
	var execute_effect := SummaryJudgementEffect.new()
	execute_effect.execute(targets)
