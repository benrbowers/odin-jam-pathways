package levels

import "src:const"
import "src:lines"
import "src:tiles"
import rl "vendor:raylib"

Level :: struct {
	is_loaded: bool,
	tiles:     [][]tiles.Tile_Type,
}

current_level: Level

unload_current_level :: proc() {
	for col in current_level.tiles {
		delete(col)
	}
	delete(current_level.tiles)

	current_level.tiles = nil
	current_level.is_loaded = false
}

draw_level :: proc(level: Level) {
	for row, x in level.tiles {
		for tile, y in row {
			if tile == .FLOOR do continue
			tiles.draw_tile(tile, tiles.Vector2i{i32(x), i32(y)})
		}
	}
}

draw_current_level :: proc() {
	draw_level(current_level)
}

load_cubes :: proc(level: Level, cubes: ^[dynamic]lines.Hyper_Cube) {
	for row, x in level.tiles {
		for tile, y in row {
			#partial switch tile {
			case .START_GREEN:
			case .START_BLUE:
			case .START_PINK:
			case .START_RED:
			case:
				continue
			}

			color: lines.Hyper_Color
			#partial switch tile {
			case .START_GREEN:
				color = .GREEN
			case .START_BLUE:
				color = .BLUE
			case .START_PINK:
				color = .PINK
			case .START_RED:
				color = .RED
			}

			pos_v := rl.Vector2{f32(x), f32(y)}
			pos_v *= const.TILE_SIZE
			pos_v += const.TILE_SIZE / 2

			append(
				cubes,
				lines.Hyper_Cube {
					color = color,
					start_tile = tiles.Vector2i{i32(x), i32(y)},
					position = pos_v,
				},
			)
		}
	}
}
load_current_cubes :: proc(cubes: ^[dynamic]lines.Hyper_Cube) {
	load_cubes(current_level, cubes)
}

get_tile :: proc(level: Level, tile: tiles.Vector2i) -> tiles.Tile_Type {
	if !level.is_loaded do return .FLOOR

	if tile.x < 0 do return .FLOOR
	if int(tile.x) >= len(level.tiles) do return .FLOOR

	if tile.y < 0 do return .FLOOR
	if int(tile.y) >= len(level.tiles[0]) do return .FLOOR

	return level.tiles[tile.x][tile.y]
}

get_current_tile :: proc(tile: tiles.Vector2i) -> tiles.Tile_Type {
	return get_tile(current_level, tile)
}

get_next_line :: proc(
	mouse_tile: tiles.Vector2i,
	cubes: [dynamic]lines.Hyper_Cube,
) -> (
	lines.Hyper_Line,
	^lines.Hyper_Cube,
	bool,
) {
	for &cube in cubes {
		if mouse_tile == cube.start_tile do continue

		last_tile: tiles.Vector2i
		if len(cube.path) == 0 {
			last_tile = cube.start_tile
		} else {
			last_tile = cube.path[len(cube.path) - 1].tile
		}

		for dir, orient in lines.orientation_vector {
			if mouse_tile == last_tile + dir {
				// Placement is valid
				line_type := lines.Line_Type.END
				for goal_dir, goal_orient in lines.orientation_vector {
					next_tile := get_current_tile(mouse_tile + goal_dir)
					if next_tile == lines.cube_goal_tiles[cube.color] {
						if goal_orient == lines.turn_right(orient) {
							line_type = .TURN_RIGHT
						} else if goal_orient == lines.turn_left(orient) {
							line_type = .TURN_LEFT
						} else {
							line_type = .LINE
						}
					}
				}
				return lines.Hyper_Line{line_type, orient, nil, mouse_tile},
					&cube,
					true
			}
		}
	}
	return lines.Hyper_Line{}, nil, false
}
