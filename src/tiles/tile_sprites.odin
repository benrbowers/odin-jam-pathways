package tiles

import "core:fmt"
import "src:lines"
import rl "vendor:raylib"

tile_sprite_paths: [Tile_Type]cstring = {
	.WALL       = "sprites/wall.png",
	.HOLE       = "sprites/hole.png",
	.GREEN_GOAL = "sprites/goal-green.png",
	.BLUE_GOAL  = "sprites/goal-blue.png",
	.PINK_GOAL  = "sprites/goal-pink.png",
	.RED_GOAL   = "sprites/goal-red.png",
}
tile_sprites: [Tile_Type]rl.Texture2D

cube_sprite_paths: [lines.Hyper_Color]cstring = {
	.GREEN = "sprites/cube-green.png",
	.BLUE  = "sprites/cube-blue.png",
	.PINK  = "sprites/cube-pink.png",
	.RED   = "sprites/cube-red.png",
}
cube_sprites: [lines.Hyper_Color]rl.Texture2D

load_tile_sprites :: proc() {
	for type in Tile_Type {
		path := tile_sprite_paths[type]
		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		tile_sprites[type] = sprite
	}
	for color in lines.Hyper_Color {
		path := cube_sprite_paths[color]
		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		cube_sprites[color] = sprite
	}
}
unload_tile_sprites :: proc() {
	for type in Tile_Type {
		rl.UnloadTexture(tile_sprites[type])
	}
	for color in lines.Hyper_Color {
		rl.UnloadTexture(cube_sprites[color])
	}
}
