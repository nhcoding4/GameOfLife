package main

import rl "github.com/gen2brain/raylib-go/raylib"

type Grid struct {
	rows, columns, cellSize int32
	color                   rl.Color
	cells                   [][]*Cell
	nextState               [][]bool
	currentState            [][]bool
	stateChan               chan [][]bool
}

func newGrid(width, height, cellSize int32, color rl.Color) *Grid {
	newGrid := &Grid{
		rows:      height / cellSize,
		columns:   width / cellSize,
		cellSize:  cellSize,
		color:     color,
		stateChan: make(chan [][]bool, 1000),
	}
	newGrid.makeStateVec()
	newGrid.makeCellGrid()
	newGrid.findCellNeighbors()

	return newGrid
}

func (g *Grid) makeStateVec() {
	for range g.rows {
		newRow := make([]bool, 0)
		newRow2 := make([]bool, 0)
		for range g.columns {
			newRow = append(newRow, false)
			newRow2 = append(newRow2, false)
		}
		g.nextState = append(g.nextState, newRow)
		g.currentState = append(g.currentState, newRow2)
	}
}

func (g *Grid) makeCellGrid() {
	for y := range g.rows {
		newRow := make([]*Cell, 0)
		for x := range g.columns {
			newRow = append(newRow, newCell(
				x*g.cellSize+1,
				y*g.cellSize+1,
				g.cellSize-1,
				x,
				y,
				g.color,
			))
		}
		g.cells = append(g.cells, newRow)
	}
}

func (g *Grid) findCellNeighbors() {
	offsets := [][]int32{{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

	for y := range g.rows {
		for x := range g.columns {
			for _, offset := range offsets {
				xOffset := (x + offset[0] + g.columns) % g.columns
				yOffset := (y + offset[1] + g.rows) % g.rows

				g.cells[y][x].neighbors = append(g.cells[y][x].neighbors, g.cells[yOffset][xOffset])
			}
		}
	}
}

func (g *Grid) createNewStates() {
	for {
		for y, row := range g.cells {
			for x, cell := range row {
				if !cell.active {
					continue
				}

				activeNeighbors := cell.activeNeighbors()

				switch activeNeighbors {
				case 3:
					g.nextState[y][x] = true
				case 2:
					g.nextState[y][x] = cell.active
				default:
					g.nextState[y][x] = false
				}

				if activeNeighbors == 0 {
					continue
				}

				for _, neighbor := range cell.neighbors {
					if neighbor.activeNeighbors() == 3 {
						g.nextState[neighbor.gridY][neighbor.gridX] = true
					}
				}

			}
		}

		g.stateChan <- g.nextState

		for y, row := range g.cells {
			for x := range row {
				g.cells[y][x].active = g.nextState[y][x]
			}
		}
	}
}

func (g *Grid) pullState() {
	if len(g.stateChan) > 0 {
		g.currentState = <-g.stateChan
	}
}

func (g *Grid) draw() {
	for y := range g.rows {
		for x := range g.columns {
			if g.currentState[y][x] {
				g.cells[y][x].draw()
			}
		}
	}
}
