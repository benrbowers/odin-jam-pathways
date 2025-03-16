package game

import "core:fmt"
import "src:const"
import "src:levels"
import "src:lines"
import "src:tiles"
import "src:ui"
import rl "vendor:raylib"

run: bool = false

Available_Levels :: enum {
	ONE,
	FOUR,
}
selected_level := Available_Levels.ONE

selection_menu_open: bool = false

user_hit_play: bool = false
user_released_play: bool = false

user_hit_reset: bool = false
user_released_reset: bool = false

user_has_won: bool = false

animation_mode: bool = false
animation_start: f64 = 0.0
preview_mode: bool = false
selected_cube: ^lines.Hyper_Cube

cubes := [dynamic]lines.Hyper_Cube{}

checker_texture: rl.Texture2D

offset := rl.Vector2{const.WINDOW_HEIGHT, const.WINDOW_HEIGHT} / 2

camera := rl.Camera2D {
	zoom   = const.ZOOM,
	offset = offset,
	target = offset / const.ZOOM,
}

reset :: proc() {
	selection_menu_open = false

	user_hit_play = false
	user_released_play = false

	user_hit_reset = false
	user_released_reset = false

	user_has_won = false

	animation_mode = false
	animation_start = 0.0
	preview_mode = false
	selected_cube = nil
}

reload :: proc() {
	if levels.current_level.is_loaded {
		levels.unload_current_level()
	}

	switch selected_level {
	case .ONE:
		levels.load_level1()
	case .FOUR:
		levels.load_level4()
	}

	clear(&cubes)
	levels.load_current_cubes(&cubes)
}

init :: proc() {
	using rl

	run = true

	InitWindow(const.WINDOW_WIDTH, const.WINDOW_HEIGHT, "HYPERLINES")

	SetTargetFPS(60)
	SetExitKey(.KEY_NULL)

	checker_texture = LoadTexture("sprites/checker.png")
	assert(checker_texture.id > 0, "Could not load checker texture.")

	lines.load_line_sprites()

	tiles.load_tile_sprites()

	ui.load_button_sprites()

	reload()
}

clean_up :: proc() {
	using rl

	UnloadTexture(checker_texture)
	lines.unload_line_sprites()
	tiles.unload_tile_sprites()
	ui.unload_button_sprites()
}

update :: proc() {
	using rl

	time := GetTime()
	mouse_world := GetScreenToWorld2D(GetMousePosition(), camera)
	mouse_tile := tiles.world_to_tile(mouse_world)

	if IsKeyPressed(.ESCAPE) {
		selection_menu_open = !selection_menu_open
	}

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
			reload()
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
			animation_start = time
		}
	}

	BeginDrawing()
	ClearBackground(Color{0, 3, 60, 255})

	BeginMode2D(camera)
	// for i: i32 = 0; i < const.CHECKER_WIDTH; i += 1 {
	// 	for j: i32 = 0; j < const.CHECKER_HEIGHT; j += 1 {
	// 		DrawTexture(
	// 			checker_texture,
	// 			i * const.CHECKER_SIZE,
	// 			j * const.CHECKER_SIZE,
	// 			WHITE,
	// 		)
	// 	}
	// }
	if levels.current_level.is_loaded {
		levels.draw_current_level()
		for cube in cubes {
			// Paths first so previews are on top
			lines.draw_cube_path(cube)
		}

		if animation_mode {
			delta_time := time - animation_start
			for &cube in cubes {
				lines.animate_cube_path(&cube, delta_time)
			}
			if lines.done_animating(cubes) {
				score: int = 0
				for cube in cubes {
					if len(cube.path) == 0 do continue
					last_line := cube.path[len(cube.path) - 1]
					if last_line.type != .END {
						score += 1
					}
				}
				if score == levels.count_current_goals() {
					user_has_won = true
				}
			}
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

					path_tile := lines.cube_path_tiles[preview_cube.color]
					levels.set_current_tile(mouse_tile, path_tile)

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
			lines.draw_cube(cube)
		}
	} // End of level drawing

	ui.draw_button(animation_mode, is_button_pressed)

	EndMode2D()
	DrawText("ESC for Menu", 10, 10, 16, WHITE)

	if user_has_won {
		DrawRectangle(
			0,
			0,
			const.WINDOW_WIDTH,
			const.WINDOW_HEIGHT,
			Color{0, 0, 0, 125},
		)

		win_text: cstring = "COMPLETE!"
		measure := MeasureText(win_text, 100)
		DrawText(
			win_text,
			(const.WINDOW_WIDTH - measure) / 2,
			(const.WINDOW_HEIGHT - 100) / 2,
			100,
			WHITE,
		)
	}

	if selection_menu_open {
		DrawRectangle(
			0,
			0,
			const.WINDOW_WIDTH,
			const.WINDOW_HEIGHT,
			Color{0, 3, 60, 255},
		)
		menu_title: cstring = "HYPERLINES"
		measure := MeasureText(menu_title, 80)
		DrawText(
			menu_title,
			(const.WINDOW_WIDTH - measure) / 2,
			40,
			80,
			WHITE,
		)
		menu_subtitle: cstring = "Select Level"
		measure = MeasureText(menu_subtitle, 40)
		DrawText(
			menu_subtitle,
			(const.WINDOW_WIDTH - measure) / 2,
			150,
			40,
			WHITE,
		)
		level_rects := [Available_Levels]Rectangle{}
		for level, i in Available_Levels {
			level_text: cstring = fmt.ctprint("Level", level)
			measure = MeasureText(level_text, 20)
			DrawText(
				level_text,
				(const.WINDOW_WIDTH - measure) / 2,
				i32(220 + i * 40),
				20,
				WHITE,
			)
			level_rects[level] = Rectangle {
				x      = f32((const.WINDOW_WIDTH - measure) / 2),
				y      = f32(220 + i * 40),
				width  = f32(measure),
				height = 20,
			}
		}

		if IsMouseButtonDown(.LEFT) {
			for level, i in Available_Levels {
				if CheckCollisionPointRec(
					GetMousePosition(),
					level_rects[level],
				) {
					selected_level = level
					reset()
					reload()
				}
			}
		}
	}
	EndDrawing()
}

parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}

shutdown :: proc() {
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			run = false
		}
	}

	return run
}
