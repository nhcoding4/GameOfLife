package main

import "core:math/rand"

Vector2 :: struct($T: typeid) {
	x, y: T,
}


// ------------------------------------------------------------------------------------------------

createGrid :: proc(randomise: b8) -> [][]b8 {
	grid := make([][]b8, Rows)

	for y in 0 ..< Rows {
		grid[y] = make([]b8, Columns)
		for x in 0 ..< Columns {
			if randomise && rand.int31_max(100) < StartingAliveChance {
				grid[y][x] = true
			}
		}
	}

	return grid
}

// ------------------------------------------------------------------------------------------------

createOffsetData :: proc() -> [][]#soa[8]Vector2(u16) {
	offsets := []Vector2(int){{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

	calculatedOffsets := make([][]#soa[8]Vector2(u16), Rows)

	for y in 0 ..< Rows {
		calculatedOffsets[y] = make([]#soa[8]Vector2(u16), Columns)

		for x in 0 ..< Columns {
			for offset, i in offsets {
				calculatedOffsets[y][x][i] = {
					u16((x + Columns + offset.x) % Columns),
					u16((y + Rows + offset.y) % Rows),
				}
			}
		}
	}

	return calculatedOffsets
}

// ------------------------------------------------------------------------------------------------

createPositionalData :: proc() -> [][]Vector2(i32) {
	data := make([][]Vector2(i32), Rows)

	for y in 0 ..< Rows {
		data[y] = make([]Vector2(i32), Columns)
		for x in 0 ..< Columns {
			data[y][x] = Vector2(i32) {
				x = i32(x) * i32(CellSize),
				y = i32(y) * i32(CellSize),
			}
		}
	}

	return data
}

// ------------------------------------------------------------------------------------------------
