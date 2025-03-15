package game

import "core:fmt"
import "src:const"
import "src:levels"
import "src:lines"
import "src:tiles"
import "vendor:raylib"

main :: proc() {
	using raylib

	InitWindow(const.WINDOW_WIDTH, const.WINDOW_HEIGHT, "HYPERLINES")
	defer CloseWindow()

	SetTargetFPS(60)

	checker_texture := LoadTexture("sprites/checker.png")
	assert(checker_texture.id > 0, "Could not load checker texture.")
	defer UnloadTexture(checker_texture)

	lines.load_line_sprites()
	defer lines.unload_line_sprites()

	tiles.load_tile_sprites()
	defer tiles.unload_tile_sprites()

	offset := Vector2{const.WINDOW_HEIGHT, const.WINDOW_HEIGHT} / 2

	camera := Camera2D {
		zoom   = const.ZOOM,
		offset = offset,
		target = offset / const.ZOOM,
	}

	preview_mode: bool = false
	selected_cube: ^lines.Hyper_Cube
	cubes: [dynamic]lines.Hyper_Cube = {}


	// TODO: Finish minimum game loop for level 1
	// - [X] Connect path to goal when at goal
	// - [ ] Play button
	// - [ ] Reset button
	// - [ ] "COMPLETE" text when you win
	levels.load_level1()
	levels.load_current_cubes(&cubes)

	for !WindowShouldClose() {
		time := GetTime()
		mouse := GetScreenToWorld2D(GetMousePosition(), camera)
		mouse_tile := tiles.world_to_tile(mouse)

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
		if levels.current_level.is_loaded {
			levels.draw_current_level()
			preview_line, preview_cube, preview_ok := levels.get_next_line(
				mouse_tile,
				cubes,
			)
			if preview_ok {
				preview_mode = true
				selected_cube = preview_cube
				lines.show_line_preview(preview_line, preview_cube, time)
				if IsMouseButtonDown(.LEFT) {
					// Place line on click
					if len(preview_cube.path) > 0 {
						last_line := &preview_cube.path[len(preview_cube.path) - 1]
						preview_type, type_ok := last_line.preview_type.?
						if type_ok {
							last_line.type = preview_type
							last_line.preview_type = nil
						}
					}
					append(&preview_cube.path, preview_line)
					selected_cube = nil
					preview_mode = false
				}
			} else if preview_mode {
				lines.straighten_cube_path(selected_cube)
				selected_cube = nil
				preview_mode = false
			}
			for cube in cubes {
				lines.draw_cube_path(cube)
				lines.draw_cube(cube)
			}
		}
		EndMode2D()

		EndDrawing()
	}
}
