package game

import "vendor:raylib"

main :: proc() {
	using raylib

	InitWindow(800, 600, "Pathways")
	defer CloseWindow()

	for !WindowShouldClose() {
		BeginDrawing()
		ClearBackground(RAYWHITE)
		DrawText("Hello, World!", 20, 20, 20, BLACK)
		EndDrawing()
	}
}
