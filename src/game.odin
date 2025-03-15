package game

import "core:fmt"
import "src:const"
import "src:levels"
import "src:lines"
import "src:tiles"
import "src:ui"
import "vendor:raylib"

Available_Levels :: enum {
	ONE,
}
selected_level := Available_Levels.ONE

user_hit_play: bool = false
user_released_play: bool = false

user_hit_reset: bool = false
user_released_reset: bool = false

animation_mode: bool = false
preview_mode: bool = false
selected_cube: ^lines.Hyper_Cube

cubes := [dynamic]lines.Hyper_Cube{}

reset :: proc() {
	user_hit_play = false
	user_released_play = false

	user_hit_reset = false
	user_released_reset = false

	animation_mode = false
	preview_mode = false
	selected_cube = nil

	clear(&cubes)
	levels.load_current_cubes(&cubes)
}

reload :: proc() {
	if levels.current_level.is_loaded {
		levels.unload_current_level()
	}

	switch selected_level {
	case .ONE:
		levels.load_level1()
	}
}

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

	ui.load_button_sprites()
	defer ui.unload_button_sprites()

	offset := Vector2{const.WINDOW_HEIGHT, const.WINDOW_HEIGHT} / 2

	camera := Camera2D {
		zoom   = const.ZOOM,
		offset = offset,
		target = offset / const.ZOOM,
	}

	// TODO: Finish minimum game loop for level 1
	// - [X] Connect path to goal when at goal
	// - [X] Play button
	// - [X] Reset button
	// - [ ] "COMPLETE" text when you win
	levels.load_level1()
	levels.load_current_cubes(&cubes)

	for !WindowShouldClose() {
		time := GetTime()
		mouse_world := GetScreenToWorld2D(GetMousePosition(), camera)
		mouse_tile := tiles.world_to_tile(mouse_world)

		is_button_pressed := ui.is_button_pressed(mouse_world)

		if animation_mode {
			if is_button_pressed && !user_hit_reset {
				user_hit_reset = true
			}
			if !is_button_pressed && user_hit_reset {
				user_released_reset = true
			}
			if user_released_reset {
				reset()
			}
		} else {
			if is_button_pressed && !user_hit_play {
				user_hit_play = true
			}
			if !is_button_pressed && user_hit_play {
				user_released_play = true
			}
			if user_released_play {
				animation_mode = true
			}
		}

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

			if animation_mode {
				// TODO: Animation mode
			} else {
				// Path drawing mode
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
			}

			for cube in cubes {
				lines.draw_cube_path(cube)
				lines.draw_cube(cube)
			}
		}

		ui.draw_button(animation_mode, is_button_pressed)

		EndMode2D()
		EndDrawing()
	}
}
