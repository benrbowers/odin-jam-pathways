package ui

import "core:fmt"
import "src:const"
import rl "vendor:raylib"

BUTTON_MARGIN :: const.TILE_SIZE * 0.5

Button_State :: enum {
	PLAY,
	PLAY_PRESSED,
	RESET,
	RESET_PRESSED,
}

// Both the same spot
button_rect := rl.Rectangle {
	x      = BUTTON_MARGIN,
	y      = const.WINDOW_HEIGHT /
		const.ZOOM - const.TILE_SIZE - BUTTON_MARGIN,
	width  = const.TILE_SIZE,
	height = const.TILE_SIZE,
}

is_button_hovered :: proc(mouse_world: rl.Vector2) -> bool {
	return rl.CheckCollisionPointRec(mouse_world, button_rect)
}

is_button_pressed :: proc(mouse_world: rl.Vector2) -> bool {
	return is_button_hovered(mouse_world) && rl.IsMouseButtonDown(.LEFT)
}

draw_button :: proc(animation_mode: bool, is_pressed: bool) {
	state: Button_State
	if animation_mode {
		if is_pressed {
			state = .RESET_PRESSED
		} else {
			state = .RESET
		}
	} else {
		if is_pressed {
			state = .PLAY_PRESSED
		} else {
			state = .PLAY
		}
	}

	sprite := button_sprites[state]
	rl.DrawTextureV(
		sprite,
		rl.Vector2{button_rect.x, button_rect.y},
		rl.WHITE,
	)
}
