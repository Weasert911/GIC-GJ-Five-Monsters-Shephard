extends CharacterBody2D

# =====================
# EXPORT VARIABLES
# =====================
@export var move_speed := 300.0
@export var jump_force := 420.0
@export var attack_duration := 0.6
@export var horn_color := "purple"

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

	# Listen to horn
	GameManager.horn_played.connect(_on_horn_played)

func _physics_process(delta):
	if attacking:
		velocity.x = dir * move_speed
	else:
		velocity.x = 0

	# Manual gravity during jump
	if attacking:
		velocity.y += 1200 * delta
	else:
		velocity.y = 0
		global_position.y = locked_y

	move_and_slide()

	# Clamp landing
	if global_position.y >= locked_y:
		global_position.y = locked_y
		velocity.y = 0

# =====================
# HORN HANDLER
# =====================
func _on_horn_played(horn: String, origin: Vector2, radius: float):
	if horn != horn_color:
		return

	if global_position.distance_to(origin) > radius:
		return

	start_jump()

# =====================
# JUMP ATTACK
# =====================
func start_jump():
	if attacking:
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0

	attacking = true
	sprite.play("attack")

	velocity.y = -jump_force

	_end_attack()

# =====================
# END ATTACK
# =====================
func _end_attack():
	await get_tree().create_timer(attack_duration).timeout
	attacking = false
	sprite.play("idle")
