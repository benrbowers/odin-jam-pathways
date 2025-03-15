package levels

import "src:const"
import "src:tiles"

load_level4 :: proc() {
	cols := make([][]tiles.Tile_Type, const.DEFAULT_LEVEL_WIDTH)
	for &col in cols {
		col = make([]tiles.Tile_Type, const.DEFAULT_LEVEL_HEIGHT)
	}
	current_level.tiles = cols

	current_level.tiles[2][3] = .START_GREEN
	current_level.tiles[8][3] = .GOAL_GREEN

	current_level.tiles[5][5] = .START_PINK
	current_level.tiles[5][1] = .GOAL_PINK

	current_level.is_loaded = true
}
