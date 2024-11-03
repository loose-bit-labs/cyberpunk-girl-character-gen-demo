extends Node3D

const sup_scene = "res://sup.tscn"
var camera : Camera3D

func _ready() -> void:
	camera = get_parent()
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_pause"):
		toggle_pause()
	if get_tree().paused and Input.is_action_just_pressed("ui_accept"):
		unpause()
		UtilMe.release_mouse()
		get_tree().change_scene_to_file(sup_scene)

func toggle_pause() -> bool:
	var paused = !get_tree().paused
	if paused:
		pause()
	else:
		unpause()
	return paused

func pause() -> bool:
	get_tree().paused = true
	show()
	UtilMe.release_mouse()
	camera.global_rotation.y = deg_to_rad(90)
	camera.global_position.y = 9.9
	return true

func unpause() -> bool:
	get_tree().paused = false
	hide()
	UtilMe.grab_mouse()
	return false
