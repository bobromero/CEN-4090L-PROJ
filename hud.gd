extends CanvasLayer


class_name playerHud

func update_score(new_score: int) -> void:
	$scoreCount.text = "Score: " + str(new_score)

func _process(delta: float) -> void:
	update_score(Player.Instance.Score)
