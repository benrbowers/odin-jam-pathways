package lines

import "core:fmt"
import "core:math"
import "src:const"
import "src:tiles"
import rl "vendor:raylib"

Vector2i :: [2]i32

PREVIEW_PULSE :: 5.0
CUBE_SPEED :: 25.0

Orientation :: enum {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

Hyper_Color :: enum {
	GREEN,
	BLUE,
	PINK,
	RED,
}

Line_Type :: enum {
	LINE,
	TURN_RIGHT,
	TURN_LEFT,
	END,
}

Hyper_Line :: struct {
	type:         Line_Type,
	orientation:  Orientation,
	preview_type: Maybe(Line_Type),
	tile:         Vector2i,
}

Hyper_Cube :: struct {
	color:              Hyper_Color,
	path:               [dynamic]Hyper_Line,
	start_tile:         Vector2i,
	position:           rl.Vector2,
	animation_finished: bool,
}

opacity :: proc(percent: u32) -> rl.Color {
	if percent > 100 do return rl.WHITE

	a := u8(percent * 255 / 100)
	return rl.Color{255, 255, 255, a}
}

orientaion_degrees: [Orientation]f32 = {
	.UP    = 0.0,
	.RIGHT = 90.0,
	.DOWN  = 180.0,
	.LEFT  = 270.0,
}
orientation_vector: [Orientation]Vector2i = {
	.UP    = Vector2i{0, -1},
	.RIGHT = Vector2i{1, 0},
	.DOWN  = Vector2i{0, 1},
	.LEFT  = Vector2i{-1, 0},
}

turn_right :: proc(orientation: Orientation) -> Orientation {
	if int(orientation) == len(Orientation) - 1 {
		return Orientation(0)
	}
	return orientation + Orientation(1)
}
turn_left :: proc(orientation: Orientation) -> Orientation {
	if int(orientation) == 0 {
		return Orientation(len(Orientation) - 1)
	}
	return orientation - Orientation(1)
}
turn_reverse :: proc(orientation: Orientation) -> Orientation {
	return turn_right(turn_right(orientation))
}

cube_goal_tiles := [Hyper_Color]tiles.Tile_Type {
	.GREEN = .GOAL_GREEN,
	.BLUE  = .GOAL_BLUE,
	.PINK  = .GOAL_PINK,
	.RED   = .GOAL_RED,
}
cube_path_tiles := [Hyper_Color]tiles.Tile_Type {
	.GREEN = .PATH_GREEN,
	.BLUE  = .PATH_BLUE,
	.PINK  = .PATH_PINK,
	.RED   = .PATH_RED,
}

show_line_preview :: proc(
	new_line: Hyper_Line,
	cube: ^Hyper_Cube,
	time: f64,
) {
	if len(cube.path) > 0 {
		last_line := &cube.path[len(cube.path) - 1]
		if last_line.orientation == new_line.orientation {
			last_line.preview_type = .LINE
		} else {
			if new_line.orientation == turn_left(last_line.orientation) {
				last_line.preview_type = .TURN_LEFT
			} else {
				last_line.preview_type = .TURN_RIGHT
			}
		}
	}

	x := f32(new_line.tile.x) * const.TILE_SIZE
	y := f32(new_line.tile.y) * const.TILE_SIZE

	sprite := line_sprites[new_line.type][cube.color]

	scale: f32 = 1.0 - 0.3 * f32(math.abs(math.sin(time * PREVIEW_PULSE)))
	offset: f32 = f32(const.TILE_SIZE) * ((1.0 - scale) / 2.0)

	sprite_width := f32(sprite.width) * scale
	sprite_height := f32(sprite.height) * scale

	pos := rl.Vector2 {
		x + offset + sprite_width / 2, // Add half width to rotate around center
		y + offset + sprite_height / 2, // Add half height to rotate around center
	}

	source_rec := rl.Rectangle{0, 0, f32(sprite.width), f32(sprite.height)}
	dest_rec := rl.Rectangle{pos.x, pos.y, sprite_width, sprite_height}
	origin := rl.Vector2{sprite_width / 2, sprite_height / 2} // Set origin to center

	rl.DrawTexturePro(
		sprite,
		source_rec,
		dest_rec,
		origin,
		orientaion_degrees[new_line.orientation],
		opacity(50),
	)
}

straighten_cube_path :: proc(cube: ^Hyper_Cube) {
	path_len := len(cube.path)

	if path_len == 0 do return

	cube.path[path_len - 1].preview_type = nil
}

draw_line :: proc(line: Hyper_Line, color: Hyper_Color) {
	x := f32(line.tile.x) * const.TILE_SIZE
	y := f32(line.tile.y) * const.TILE_SIZE

	sprite: rl.Texture2D
	preview_type, type_ok := line.preview_type.?
	if type_ok {
		sprite = line_sprites[preview_type][color]
	} else {
		sprite = line_sprites[line.type][color]
	}

	sprite_width := f32(sprite.width)
	sprite_height := f32(sprite.height)

	pos := rl.Vector2 {
		x + sprite_width / 2, // Add half width to rotate around center
		y + sprite_height / 2, // Add half height to rotate around center
	}

	source_rec := rl.Rectangle{0, 0, f32(sprite.width), f32(sprite.height)}
	dest_rec := rl.Rectangle{pos.x, pos.y, sprite_width, sprite_height}
	origin := rl.Vector2{sprite_width / 2, sprite_height / 2} // Set origin to center

	rl.DrawTexturePro(
		sprite,
		source_rec,
		dest_rec,
		origin,
		orientaion_degrees[line.orientation],
		rl.WHITE,
	)
}

draw_cube :: proc(cube: Hyper_Cube) {
	sprite := cube_sprites[cube.color]
	half_w := f32(sprite.width) / 2
	offset := rl.Vector2{-half_w, -f32(sprite.height) + half_w} // Center at "base" of cube

	rl.DrawTextureV(sprite, cube.position + offset, rl.WHITE)
}

draw_cube_path :: proc(cube: Hyper_Cube) {
	for line in cube.path {
		draw_line(line, cube.color)
	}
}

animate_cube_path :: proc(cube: ^Hyper_Cube, delta_time: f64) {
	if len(cube.path) == 0 {
		return
	}
	if cube.animation_finished {
		return
	}
	// Distance travelled per tile is tile size, TURNS INCLUDED
	path_len := len(cube.path)
	last_line := cube.path[path_len - 1]
	offset: f64 = 0.0
	if last_line.type == .END {
		offset = const.TILE_SIZE / 2
	}

	distance_travelled := delta_time * CUBE_SPEED
	path_distance := f64(path_len) * const.TILE_SIZE - offset

	if distance_travelled >= path_distance {
		last_tile: tiles.Vector2i
		if last_line.type == .END {
			last_tile = last_line.tile
		} else {
			orientation := last_line.orientation
			switch last_line.type {
			case .LINE:
				dir := orientation_vector[orientation]
				last_tile = last_line.tile + dir
			case .TURN_RIGHT:
				dir := orientation_vector[turn_right(orientation)]
				last_tile = last_line.tile + dir
			case .TURN_LEFT:
				dir := orientation_vector[turn_left(orientation)]
				last_tile = last_line.tile + dir
			case .END:
			}
		}
		pos := tiles.tile_center(last_tile)
		cube.position = pos
		cube.animation_finished = true
		return
	}

	line_index: int = int(math.floor(distance_travelled / const.TILE_SIZE))
	current_line := cube.path[line_index]

	distance_remaining :=
		f64(line_index + 1) * const.TILE_SIZE - distance_travelled
	dir := orientation_vector[current_line.orientation]
	dif_center: f32 = (const.TILE_SIZE / 2 - f32(distance_remaining))
	pos := tiles.tile_center(current_line.tile)

	switch current_line.type {
	case .END:
		fallthrough
	case .LINE:
		pos += rl.Vector2{f32(dir.x), f32(dir.y)} * dif_center
	case .TURN_RIGHT:
		if dif_center < 0 {
			pos += rl.Vector2{f32(dir.x), f32(dir.y)} * dif_center
		} else {
			right_dir :=
				orientation_vector[turn_right(current_line.orientation)]
			pos += rl.Vector2{f32(right_dir.x), f32(right_dir.y)} * dif_center
		}
	case .TURN_LEFT:
		if dif_center < 0 {
			pos += rl.Vector2{f32(dir.x), f32(dir.y)} * dif_center
		} else {
			left_dir := orientation_vector[turn_left(current_line.orientation)]
			pos += rl.Vector2{f32(left_dir.x), f32(left_dir.y)} * dif_center
		}
	}

	cube.position = pos
}

done_animating :: proc(cubes: [dynamic]Hyper_Cube) -> bool {
	for cube in cubes {
		if !cube.animation_finished {
			return false
		}
	}
	return true
}
