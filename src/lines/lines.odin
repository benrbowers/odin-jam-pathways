package lines

import "core:fmt"
import "core:math"
import "src:const"
import rl "vendor:raylib"

Vector2i :: [2]int

Orientation :: enum {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

Hyper_Color :: enum {
	GREEN,
	BLUE,
	PINK,
	RED,
}

Line_Type :: enum {
	LINE,
	TURN,
	END,
}

Hyper_Line :: struct {
	type:        Line_Type,
	orientation: Orientation,
	tile:        Vector2i,
}

Hyper_Path :: struct {
	color: Hyper_Color,
	lines: [dynamic]Hyper_Line,
}

Hyper_Cube :: struct {
	color:      Hyper_Color,
	path:       Hyper_Path,
	start_tile: Vector2i,
	position:   rl.Vector2,
}

opacity :: proc(percent: u32) -> rl.Color {
	if percent > 100 do return rl.WHITE

	a := u8(percent * 255 / 100)
	return rl.Color{255, 255, 255, a}
}

PREVIEW_PULSE :: 3.5

orientaion_degrees: [Orientation]f32 = {
	.UP    = 0.0,
	.RIGHT = 90.0,
	.DOWN  = 180.0,
	.LEFT  = 270.0,
}

show_line_preview :: proc(
	line: Hyper_Line,
	color: Hyper_Color,
	time: f64,
) {
	x := f32(line.tile.x) * const.TILE_SIZE
	y := f32(line.tile.y) * const.TILE_SIZE

	sprite := line_sprites[line.type][color]

	scale: f32 = 1.0 - 0.3 * f32(math.abs(math.sin(time * PREVIEW_PULSE)))
	offset: f32 = f32(const.TILE_SIZE) * ((1.0 - scale) / 2.0)

	sprite_width := f32(sprite.width) * scale
	sprite_height := f32(sprite.height) * scale

	pos := rl.Vector2 {
		x + offset + sprite_width / 2, // Add half width to rotate around center
		y + offset + sprite_height / 2, // Add half height to rotate around center
	}

	source_rec := rl.Rectangle{0, 0, f32(sprite.width), f32(sprite.height)}
	dest_rec := rl.Rectangle{pos.x, pos.y, sprite_width, sprite_height}
	origin := rl.Vector2{sprite_width / 2, sprite_height / 2} // Set origin to center

	rl.DrawTexturePro(
		sprite,
		source_rec,
		dest_rec,
		origin,
		orientaion_degrees[line.orientation],
		opacity(50),
	)
}
