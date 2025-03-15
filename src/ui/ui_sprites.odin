package ui

import "core:fmt"
import rl "vendor:raylib"

button_sprite_paths := [Button_State]cstring {
	.PLAY          = "sprites/play.png",
	.PLAY_PRESSED  = "sprites/play-pressed.png",
	.RESET         = "sprites/reset.png",
	.RESET_PRESSED = "sprites/reset-pressed.png",
}
button_sprites := [Button_State]rl.Texture2D{}


load_button_sprites :: proc() {
	for button in Button_State {
		path := button_sprite_paths[button]
		sprite := rl.LoadTexture(path)

		assert(sprite.id > 0, fmt.tprint("Failed to load:", path))
		button_sprites[button] = sprite
	}
}
unload_button_sprites :: proc() {
	for button in Button_State {
		rl.UnloadTexture(button_sprites[button])
	}
}
