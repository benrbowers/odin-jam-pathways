package lines

import "core:fmt"
import rl "vendor:raylib"

line_sprite_paths: [Line_Type][Hyper_Color]cstring = {
	.LINE = {
		.GREEN = "sprites/line-green.png",
		.BLUE = "sprites/line-blue.png",
		.PINK = "sprites/line-pink.png",
		.RED = "sprites/line-red.png",
	},
	.TURN = {
		.GREEN = "sprites/turn-green.png",
		.BLUE = "sprites/turn-blue.png",
		.PINK = "sprites/turn-pink.png",
		.RED = "sprites/turn-red.png",
	},
	.END = {
		.GREEN = "sprites/end-green.png",
		.BLUE = "sprites/end-blue.png",
		.PINK = "sprites/end-pink.png",
		.RED = "sprites/end-red.png",
	},
}
line_sprites: [Line_Type][Hyper_Color]rl.Texture2D = #partial{}

load_line_sprites :: proc() {
	for type in Line_Type {
		for color in Hyper_Color {
			path := line_sprite_paths[type][color]
			sprite := rl.LoadTexture(path)

			assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
			line_sprites[type][color] = sprite
		}
	}
}
unload_line_sprites :: proc() {
	for type in Line_Type {
		for color in Hyper_Color {
			rl.UnloadTexture(line_sprites[type][color])
		}
	}
}
