package tiles

import "core:fmt"
import rl "vendor:raylib"

tile_sprite_paths := #partial [Tile_Type]cstring {
	.WALL        = "sprites/wall.png",
	.HOLE        = "sprites/hole.png",
	.START_GREEN = "sprites/start-green.png",
	.START_BLUE  = "sprites/start-blue.png",
	.START_PINK  = "sprites/start-pink.png",
	.START_RED   = "sprites/start-red.png",
	.GOAL_GREEN  = "sprites/goal-green.png",
	.GOAL_BLUE   = "sprites/goal-blue.png",
	.GOAL_PINK   = "sprites/goal-pink.png",
	.GOAL_RED    = "sprites/goal-red.png",
}
tile_sprites := [Tile_Type]rl.Texture2D{}


load_tile_sprites :: proc() {
	for path, type in tile_sprite_paths {
		if path == "" do continue

		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		tile_sprites[type] = sprite
	}
}
unload_tile_sprites :: proc() {
	for path, type in tile_sprite_paths {
		if path == "" do continue

		rl.UnloadTexture(tile_sprites[type])
	}
}
