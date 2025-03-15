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
	if current_level.is_loaded {
		draw_level(current_level)
	}
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
