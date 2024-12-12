extends Camera2D

class_name PlayerCamera

static var Instance : PlayerCamera

@onready var TransitionAnim = $SceneTransition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Instance = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var pos : Vector2 = Vector2.ZERO
	for e in enemies:
		pos += (e as Node2D).global_position
	global_position = Player.Instance.global_position
	


func TransitionIn():
	TransitionAnim.get_parent().global_position = Player.Instance.global_position
	TransitionAnim.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
func TransitionOut():
	TransitionAnim.get_parent().global_position = Player.Instance.global_position
	TransitionAnim.play("fade_out")
