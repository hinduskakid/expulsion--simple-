class_name SummaryJudgementEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			if target.stats.is_downed:
				print("Summary Judgement executed the enemy!")
				target.queue_free()
			else:
				print("Summary Judgement has no effect - enemy is not downed!")
