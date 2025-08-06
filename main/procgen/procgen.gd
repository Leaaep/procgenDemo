class_name Procgen
extends Node

var x_axis: int = 0
var y_axis: int = 0
var array: Array = []
const grid_width: int = 5
const grid_height: int = 5
var rng := RandomNumberGenerator.new()

enum chunk_types {
	START_CHUNK_PRELOAD,
	MAIN_CHUNK_01_PRELOAD, 
	MAIN_CHUNK_02_PRELOAD, 
	MAIN_CHUNK_03_PRELOAD, 
	MAIN_CHUNK_04_PRELOAD,
	OPTIONAL_CHUNK_PRELOAD,
	END_CHUNK_PRELOAD,
	NO_CHUNK_TYPE
}

var main_chunk_01_preload := preload("res://main/procgen/chunk/main_chunks/main_chunk_01.tscn")
var main_chunk_02_preload := preload("res://main/procgen/chunk/main_chunks/main_chunk_02.tscn")
var main_chunk_03_preload := preload("res://main/procgen/chunk/main_chunks/main_chunk_03.tscn")
var main_chunk_04_preload := preload("res://main/procgen/chunk/main_chunks/main_chunk_04.tscn")
var start_chunk_preload := preload("res://main/procgen/chunk/start_chunk/entry_chunk.tscn")
var end_chunk_preload := preload("res://main/procgen/chunk/end_chunks/end_chunk.tscn")
var optional_chunk_preload := preload("res://main/procgen/chunk/optional_chunks/optional_chunk.tscn")

func _ready() -> void:
	initalize_array()
	start_chunk()
	define_chunk_path()
	instantiate_chunk_path()

func define_chunk_path() -> void:
	while true:
		if not y_axis == grid_height - 1:
			match x_axis:
				4:
					if not array[x_axis][y_axis] == chunk_types.START_CHUNK_PRELOAD:
						mark_chunk(chunk_types.MAIN_CHUNK_03_PRELOAD)
					y_axis += 1
					mark_chunk(chunk_types.MAIN_CHUNK_02_PRELOAD)
					x_axis -= 1
					mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
				0:
					if not array[x_axis][y_axis] == chunk_types.START_CHUNK_PRELOAD:
						mark_chunk(chunk_types.MAIN_CHUNK_03_PRELOAD)
					y_axis += 1
					mark_chunk(chunk_types.MAIN_CHUNK_02_PRELOAD)
					x_axis += 1
					mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
				_:
					var random_number := rng.randi_range(1, 5)
					match random_number:
						1:
							if array[x_axis - 1][y_axis] == chunk_types.NO_CHUNK_TYPE:
								x_axis -= 1
								mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
						2:
							if array[x_axis - 1][y_axis] == chunk_types.NO_CHUNK_TYPE:
								x_axis -= 1
								mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
						3:
							if array[x_axis + 1][y_axis] == chunk_types.NO_CHUNK_TYPE:
								x_axis += 1
								mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
						4:
							if array[x_axis + 1][y_axis] == chunk_types.NO_CHUNK_TYPE:
								x_axis += 1
								mark_chunk(chunk_types.MAIN_CHUNK_01_PRELOAD)
						5:
							if array[x_axis][y_axis - 1] == chunk_types.MAIN_CHUNK_03_PRELOAD:
								array[x_axis][y_axis] = chunk_types.MAIN_CHUNK_04_PRELOAD
								y_axis += 1
								array[x_axis][y_axis] = chunk_types.MAIN_CHUNK_02_PRELOAD
							elif array[x_axis][y_axis + 1] == chunk_types.NO_CHUNK_TYPE:
								if not array[x_axis][y_axis] == chunk_types.START_CHUNK_PRELOAD:
									mark_chunk(chunk_types.MAIN_CHUNK_03_PRELOAD)
								y_axis += 1
								mark_chunk(chunk_types.MAIN_CHUNK_02_PRELOAD)
		else:
			mark_chunk(chunk_types.END_CHUNK_PRELOAD)
			break

func start_chunk() -> void:
	var random_number := rng.randi_range(1, 3)
	match random_number:
		1:
			x_axis = 1
			mark_chunk(chunk_types.START_CHUNK_PRELOAD)
		2:
			x_axis = 2
			mark_chunk(chunk_types.START_CHUNK_PRELOAD)
		3:
			x_axis = 3
			mark_chunk(chunk_types.START_CHUNK_PRELOAD)

func instantiate_chunk_path() -> void:
	var coordinates : int
	for number_y in grid_height:
		for number_x in grid_width:
			y_axis = number_y
			x_axis = number_x
			coordinates = array[x_axis][y_axis]
			match coordinates:
				chunk_types.MAIN_CHUNK_01_PRELOAD:
					instantiate_chunk(main_chunk_01_preload)
				chunk_types.MAIN_CHUNK_02_PRELOAD:
					instantiate_chunk(main_chunk_02_preload)
				chunk_types.MAIN_CHUNK_03_PRELOAD:
					instantiate_chunk(main_chunk_03_preload)
				chunk_types.MAIN_CHUNK_04_PRELOAD:
					instantiate_chunk(main_chunk_04_preload)
				chunk_types.START_CHUNK_PRELOAD:
					instantiate_chunk(start_chunk_preload)
				chunk_types.END_CHUNK_PRELOAD:
					instantiate_chunk(end_chunk_preload)
				_:
					instantiate_chunk(optional_chunk_preload)

# Calculates Vector Position
func current_coordinates() -> Vector2:
	var x_result := x_axis * 256
	var y_result := y_axis * -256
	return Vector2(x_result, y_result)

# Loads Preloaded Chunk and writes chunk_type into array
func mark_chunk(marker_name : chunk_types) -> void:
	array[x_axis][y_axis] = marker_name

func instantiate_chunk(packed_scene : PackedScene) -> void:
	var instantiated_scene := packed_scene.instantiate()
	get_viewport().get_child(0).add_child(instantiated_scene)
	instantiated_scene.set_position(current_coordinates())

# Fills the 2d array with "empty"
func initalize_array() -> void:
		for i in grid_width:
			array.append([])
			for j in grid_height:
				array[i].append(chunk_types.NO_CHUNK_TYPE)
