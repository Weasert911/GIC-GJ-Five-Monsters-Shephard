extends CharacterBody2D

# =====================
# EXPORT VARIABLES
# =====================
@export var attack_speed := 420.0
@export var attack_duration := 0.8
@export var horn_color := "orange"

# =====================
# NODES
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# =====================
# STATE
# =====================
var attacking := false
var dir := 1
var locked_y := 0.0

func _ready():
	add_to_group("enemy")
	locked_y = global_position.y
	sprite.play("idle")

	# Listen to horn globally
	GameManager.horn_played.connect(_on_horn_played)

func _physics_process(delta):
	if attacking:
		velocity.x = dir * attack_speed
	else:
		velocity.x = 0

	# HARD Y lock
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

	start_attack()

# =====================
# ATTACK LOGIC
# =====================
func start_attack():
	if attacking:
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0

	attacking = true
	sprite.play("walk")

	_end_attack()

# =====================
# STOP ATTACK
# =====================
func _end_attack():
	await get_tree().create_timer(attack_duration).timeout
	attacking = false
	velocity.x = 0
	sprite.play("idle")
