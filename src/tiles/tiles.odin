package tiles

import "core:fmt"
import "src:const"
import rl "vendor:raylib"

Vector2i :: [2]i32

Tile_Type :: enum {
	FLOOR,
	WALL,
	WALL_BROKEN,
	HOLE,
	START_GREEN,
	START_BLUE,
	START_PINK,
	START_RED,
	GOAL_GREEN,
	GOAL_BLUE,
	GOAL_PINK,
	GOAL_RED,
	PATH_GREEN,
	PATH_BLUE,
	PATH_PINK,
	PATH_RED,
}

world_to_tile :: proc(world_pos: rl.Vector2) -> Vector2i {
	x := i32(world_pos.x) / const.TILE_SIZE
	y := i32(world_pos.y) / const.TILE_SIZE

	return Vector2i{x, y}
}

draw_tile :: proc(tile_type: Tile_Type, tile_pos: Vector2i) {
	rl.DrawTexture(
		tile_sprites[tile_type],
		tile_pos.x * const.TILE_SIZE,
		tile_pos.y * const.TILE_SIZE,
		rl.WHITE,
	)
}
