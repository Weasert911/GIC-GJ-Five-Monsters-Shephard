extends CharacterBody2D

# =====================
# EXPORT VARIABLES
# =====================
@export var run_speed := 450.0
@export var attack_duration := 0.7
@export var horn_color := "red"

# =====================
# NODES
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# =====================
# STATE
# =====================
var running := false
var dir := 1
var locked_y := 0.0

func _ready():
	add_to_group("enemy")
	locked_y = global_position.y
	sprite.play("idle")

	GameManager.horn_played.connect(_on_horn_played)

func _physics_process(delta):
	if running:
		velocity.x = dir * run_speed
	else:
		velocity.x = 0

	# Hard Y lock
	velocity.y = 0
	global_position.y = locked_y

	move_and_slide()

# =====================
# HORN HANDLER
# =====================
func _on_horn_played(horn: String, origin: Vector2, radius: float):
	if horn != horn_color:
		return

	if global_position.distance_to(origin) > radius:
		return

	start_run()

# =====================
# RUN ATTACK
# =====================
func start_run():
	if running:
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0

	running = true
	sprite.play("run")

	_end_run()

# =====================
# END RUN
# =====================
func _end_run():
	await get_tree().create_timer(attack_duration).timeout
	running = false
	sprite.play("idle")
