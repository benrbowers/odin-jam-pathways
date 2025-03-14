package game

import "core:fmt"
import "src:const"
import "src:lines"
import "src:tiles"
import "vendor:raylib"

main :: proc() {
	using raylib

	InitWindow(const.WINDOW_WIDTH, const.WINDOW_HEIGHT, "HYPERLINES")
	defer CloseWindow()

	checker_texture := LoadTexture("sprites/checker.png")
	assert(checker_texture.id > 0, "Could not load checker texture.")
	defer UnloadTexture(checker_texture)

	lines.load_line_sprites()
	defer lines.unload_line_sprites()

	tiles.load_tile_sprites()
	defer tiles.unload_tile_sprites()

	camera := Camera2D {
		zoom   = const.ZOOM,
		offset = Vector2{const.WINDOW_WIDTH / 2, const.WINDOW_HEIGHT / 2},
		target = Vector2{const.WINDOW_WIDTH / 2, const.WINDOW_HEIGHT / 2},
	}


	for !WindowShouldClose() {
		time := GetTime()
		mouse := GetScreenToWorld2D(GetMousePosition(), camera)

		BeginDrawing()
		ClearBackground(Color{0, 3, 60, 255})

		BeginMode2D(camera)
		for i: i32 = 0; i < const.CHECKER_WIDTH; i += 1 {
			for j: i32 = 0; j < const.CHECKER_HEIGHT; j += 1 {
				DrawTexture(
					checker_texture,
					i * const.CHECKER_SIZE,
					j * const.CHECKER_SIZE,
					WHITE,
				)
			}
		}
		lines.show_line_preview(
			{.END, .DOWN, tiles.world_to_tile(mouse)},
			.RED,
			time,
		)
		EndMode2D()

		EndDrawing()
	}
}
