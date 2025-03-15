package lines

import "core:fmt"
import rl "vendor:raylib"

line_sprite_paths := [Line_Type][Hyper_Color]cstring {
	.LINE = {
		.GREEN = "sprites/line-green.png",
		.BLUE = "sprites/line-blue.png",
		.PINK = "sprites/line-pink.png",
		.RED = "sprites/line-red.png",
	},
	.TURN_RIGHT = {
		.GREEN = "sprites/turn-right-green.png",
		.BLUE = "sprites/turn-right-blue.png",
		.PINK = "sprites/turn-right-pink.png",
		.RED = "sprites/turn-right-red.png",
	},
	.TURN_LEFT = {
		.GREEN = "sprites/turn-left-green.png",
		.BLUE = "sprites/turn-left-blue.png",
		.PINK = "sprites/turn-left-pink.png",
		.RED = "sprites/turn-left-red.png",
	},
	.END = {
		.GREEN = "sprites/end-green.png",
		.BLUE = "sprites/end-blue.png",
		.PINK = "sprites/end-pink.png",
		.RED = "sprites/end-red.png",
	},
}
line_sprites := [Line_Type][Hyper_Color]rl.Texture2D{}

cube_sprite_paths: [Hyper_Color]cstring = {
	.GREEN = "sprites/cube-green.png",
	.BLUE  = "sprites/cube-blue.png",
	.PINK  = "sprites/cube-pink.png",
	.RED   = "sprites/cube-red.png",
}
cube_sprites: [Hyper_Color]rl.Texture2D

load_line_sprites :: proc() {
	for type in Line_Type {
		for color in Hyper_Color {
			path := line_sprite_paths[type][color]
			sprite := rl.LoadTexture(path)

			assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
			line_sprites[type][color] = sprite
		}
	}
	for color in Hyper_Color {
		path := cube_sprite_paths[color]
		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		cube_sprites[color] = sprite
	}
}
unload_line_sprites :: proc() {
	for type in Line_Type {
		for color in Hyper_Color {
			rl.UnloadTexture(line_sprites[type][color])
		}
	}
	for color in Hyper_Color {
		rl.UnloadTexture(cube_sprites[color])
	}
}
