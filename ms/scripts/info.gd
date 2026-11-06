extends Control

@onready var label: Label = $Panel/Label

var lines := [
	"CONTROLS",
	"Move : A / D",
	"Jump : Space",
	"Switch Horn : F",
	"Play Horn : Q",
	"Place Portal : E",
	"",
	"TIPS",
	"Use color-coded horns for their respective monsters",
	"When standing on a spawned portal, press E to teleport",
	"You cannot return to previous tiers",
	"Survive. Use portals wisely.",
	"",
	"Press ENTER to continue."
]

const MAX_VISIBLE_LINES := 5
const REMOVE_COUNT := 3

var visible_lines: Array[String] = []

func _ready():
	_show_lines()

func _show_lines():
	label.text = ""
	label.visible_characters = 0

	for line in lines:
		# Add new line
		visible_lines.append(line)

		# Trim old lines if needed
		if visible_lines.size() > MAX_VISIBLE_LINES:
			for i in range(REMOVE_COUNT):
				if visible_lines.size() > 0:
					visible_lines.pop_front()

		# Rebuild text
		label.text = ""
		for l in visible_lines:
			label.text += l + "\n"

		# Animate only the last line
		var chars_before = label.text.length() - (line.length() + 1)
		label.visible_characters = chars_before

		while label.visible_characters < label.text.length():
			label.visible_characters += 1
			await get_tree().create_timer(0.05).timeout

		await get_tree().create_timer(0.5).timeout

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
