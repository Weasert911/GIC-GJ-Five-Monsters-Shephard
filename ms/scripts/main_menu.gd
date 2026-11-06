extends Control

@onready var play_btn: Button = $Buttons/Play
@onready var exit_btn: Button = $Buttons/Exit

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Info.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
