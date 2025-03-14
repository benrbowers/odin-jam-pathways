package tiles

import "core:fmt"
import "src:const"
import "src:lines"
import rl "vendor:raylib"

Vector2i :: [2]int

Tile_Type :: enum {
	WALL,
	HOLE,
	GREEN_GOAL,
	BLUE_GOAL,
	PINK_GOAL,
	RED_GOAL,
}

Tile :: struct {
	type:     Tile_Type,
	position: Vector2i,
}

Hyper_Cube :: struct {
	color:    lines.Hyper_Color,
	position: rl.Vector2,
}

world_to_tile :: proc(world_pos: rl.Vector2) -> Vector2i {
	x := int(world_pos.x) / const.TILE_SIZE
	y := int(world_pos.y) / const.TILE_SIZE

	return Vector2i{x, y}
}
