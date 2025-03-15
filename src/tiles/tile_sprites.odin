package tiles

import "core:fmt"
import rl "vendor:raylib"

tile_sprite_paths: [Tile_Type]cstring = {
	.FLOOR       = "",
	.WALL        = "sprites/wall.png",
	.HOLE        = "sprites/hole.png",
	.WALL_BROKEN = "sprites/wall.png",
	.START_GREEN = "sprites/start-green.png",
	.START_BLUE  = "sprites/start-blue.png",
	.START_PINK  = "sprites/start-pink.png",
	.START_RED   = "sprites/start-red.png",
	.GOAL_GREEN  = "sprites/goal-green.png",
	.GOAL_BLUE   = "sprites/goal-blue.png",
	.GOAL_PINK   = "sprites/goal-pink.png",
	.GOAL_RED    = "sprites/goal-red.png",
}
tile_sprites: [Tile_Type]rl.Texture2D


load_tile_sprites :: proc() {
	for type in Tile_Type {
		if type == .FLOOR do continue

		path := tile_sprite_paths[type]
		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		tile_sprites[type] = sprite
	}
}
unload_tile_sprites :: proc() {
	for type in Tile_Type {
		if type == .FLOOR do continue

		rl.UnloadTexture(tile_sprites[type])
	}
}
