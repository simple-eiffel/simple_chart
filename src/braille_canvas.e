note
	description: "[
		High-resolution terminal graphics using Unicode Braille patterns.
		Each character cell contains a 2x4 grid of dots (8 dots total).
		Unicode range U+2800-U+28FF encodes all 256 possible patterns.

		Coordinate system:
		- Origin (0,0) is top-left
		- X increases rightward
		- Y increases downward
		- Canvas width in dots = char_width * 2
		- Canvas height in dots = char_height * 4
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	BRAILLE_CANVAS

create
	make

feature {NONE} -- Initialization

	make (a_char_width, a_char_height: INTEGER)
			-- Create canvas with dimensions in character cells.
		require
			width_positive: a_char_width > 0
			height_positive: a_char_height > 0
		do
			char_width := a_char_width
			char_height := a_char_height
			create cells.make_filled (0, 0, char_width * char_height - 1)
		ensure
			width_set: char_width = a_char_width
			height_set: char_height = a_char_height
			cells_cleared: across cells as c all c = 0 end
		end

feature -- Access

	char_width: INTEGER
			-- Width in character cells.

	char_height: INTEGER
			-- Height in character cells.

	dot_width: INTEGER
			-- Width in dots (2 dots per character).
		do
			Result := char_width * 2
		ensure
			correct: Result = char_width * 2
		end

	dot_height: INTEGER
			-- Height in dots (4 dots per character).
		do
			Result := char_height * 4
		ensure
			correct: Result = char_height * 4
		end

	is_set (a_x, a_y: INTEGER): BOOLEAN
			-- Is dot at (a_x, a_y) set?
		require
			x_valid: a_x >= 0 and a_x < dot_width
			y_valid: a_y >= 0 and a_y < dot_height
		local
			l_cell_x, l_cell_y, l_cell_index: INTEGER
			l_dot_x, l_dot_y: INTEGER
			l_mask: INTEGER
		do
			l_cell_x := a_x // 2
			l_cell_y := a_y // 4
			l_cell_index := l_cell_y * char_width + l_cell_x
			l_dot_x := a_x \\ 2
			l_dot_y := a_y \\ 4
			l_mask := dot_mask (l_dot_x, l_dot_y)
			Result := (cells [l_cell_index] & l_mask) /= 0
		end

feature -- Element change

	set_dot (a_x, a_y: INTEGER)
			-- Set dot at (a_x, a_y).
		require
			x_valid: a_x >= 0 and a_x < dot_width
			y_valid: a_y >= 0 and a_y < dot_height
		local
			l_cell_x, l_cell_y, l_cell_index: INTEGER
			l_dot_x, l_dot_y: INTEGER
			l_mask: INTEGER
		do
			l_cell_x := a_x // 2
			l_cell_y := a_y // 4
			l_cell_index := l_cell_y * char_width + l_cell_x
			l_dot_x := a_x \\ 2
			l_dot_y := a_y \\ 4
			l_mask := dot_mask (l_dot_x, l_dot_y)
			cells [l_cell_index] := cells [l_cell_index] | l_mask
		ensure
			dot_set: is_set (a_x, a_y)
		end

	clear_dot (a_x, a_y: INTEGER)
			-- Clear dot at (a_x, a_y).
		require
			x_valid: a_x >= 0 and a_x < dot_width
			y_valid: a_y >= 0 and a_y < dot_height
		local
			l_cell_x, l_cell_y, l_cell_index: INTEGER
			l_dot_x, l_dot_y: INTEGER
			l_mask: INTEGER
		do
			l_cell_x := a_x // 2
			l_cell_y := a_y // 4
			l_cell_index := l_cell_y * char_width + l_cell_x
			l_dot_x := a_x \\ 2
			l_dot_y := a_y \\ 4
			l_mask := dot_mask (l_dot_x, l_dot_y)
			cells [l_cell_index] := cells [l_cell_index] & l_mask.bit_not
		ensure
			dot_cleared: not is_set (a_x, a_y)
		end

	clear
			-- Clear all dots.
		do
			cells.fill_with (0)
		ensure
			all_cleared: across cells as c all c = 0 end
		end

feature -- Drawing primitives

	draw_point (a_x, a_y: INTEGER)
			-- Draw a single point (same as set_dot but clipped).
		do
			if a_x >= 0 and a_x < dot_width and a_y >= 0 and a_y < dot_height then
				set_dot (a_x, a_y)
			end
		end

	draw_line (a_x1, a_y1, a_x2, a_y2: INTEGER)
			-- Draw line from (a_x1, a_y1) to (a_x2, a_y2) using Bresenham's algorithm.
		local
			l_dx, l_dy, l_sx, l_sy, l_err, l_e2: INTEGER
			l_x, l_y: INTEGER
		do
			l_x := a_x1
			l_y := a_y1
			l_dx := (a_x2 - a_x1).abs
			l_dy := (a_y2 - a_y1).abs
			if a_x1 < a_x2 then l_sx := 1 else l_sx := -1 end
			if a_y1 < a_y2 then l_sy := 1 else l_sy := -1 end
			l_err := l_dx - l_dy

			from
			until
				l_x = a_x2 and l_y = a_y2
			loop
				draw_point (l_x, l_y)
				l_e2 := 2 * l_err
				if l_e2 > -l_dy then
					l_err := l_err - l_dy
					l_x := l_x + l_sx
				end
				if l_e2 < l_dx then
					l_err := l_err + l_dx
					l_y := l_y + l_sy
				end
			end
			draw_point (a_x2, a_y2)
		end

	draw_rect (a_x, a_y, a_w, a_h: INTEGER)
			-- Draw rectangle outline.
		require
			width_positive: a_w > 0
			height_positive: a_h > 0
		do
			draw_line (a_x, a_y, a_x + a_w - 1, a_y)
			draw_line (a_x + a_w - 1, a_y, a_x + a_w - 1, a_y + a_h - 1)
			draw_line (a_x + a_w - 1, a_y + a_h - 1, a_x, a_y + a_h - 1)
			draw_line (a_x, a_y + a_h - 1, a_x, a_y)
		end

	fill_rect (a_x, a_y, a_w, a_h: INTEGER)
			-- Fill rectangle.
		require
			width_positive: a_w > 0
			height_positive: a_h > 0
		local
			l_row, l_col: INTEGER
		do
			from l_row := a_y until l_row >= a_y + a_h loop
				from l_col := a_x until l_col >= a_x + a_w loop
					draw_point (l_col, l_row)
					l_col := l_col + 1
				end
				l_row := l_row + 1
			end
		end

feature -- Output

	as_string: STRING_32
			-- Render canvas as Unicode braille string.
		local
			l_row, l_col, l_cell_index: INTEGER
		do
			create Result.make (char_width * char_height + char_height)
			from l_row := 0 until l_row >= char_height loop
				from l_col := 0 until l_col >= char_width loop
					l_cell_index := l_row * char_width + l_col
					Result.append_character (braille_char (cells [l_cell_index]))
					l_col := l_col + 1
				end
				if l_row < char_height - 1 then
					Result.append_character ('%N')
				end
				l_row := l_row + 1
			end
		ensure
			result_attached: Result /= Void
		end

	as_string_8: STRING
			-- Render canvas as UTF-8 string (for terminal output).
		do
			Result := as_string.to_string_8
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	cells: ARRAY [INTEGER]
			-- Cell data (8-bit patterns for each character cell).

	Braille_base: INTEGER = 0x2800
			-- Unicode braille base character.

	braille_char (a_pattern: INTEGER): CHARACTER_32
			-- Braille character for given 8-bit pattern.
		require
			pattern_valid: a_pattern >= 0 and a_pattern <= 255
		do
			Result := (Braille_base + a_pattern).to_character_32
		end

	dot_mask (a_dot_x, a_dot_y: INTEGER): INTEGER
			-- Bit mask for dot at position (a_dot_x, a_dot_y) within a cell.
			-- Braille dot layout:
			--   1 4     (bits 0, 3)
			--   2 5     (bits 1, 4)
			--   3 6     (bits 2, 5)
			--   7 8     (bits 6, 7)
		require
			x_valid: a_dot_x >= 0 and a_dot_x <= 1
			y_valid: a_dot_y >= 0 and a_dot_y <= 3
		do
			inspect a_dot_y
			when 0 then
				if a_dot_x = 0 then Result := 0x01 else Result := 0x08 end
			when 1 then
				if a_dot_x = 0 then Result := 0x02 else Result := 0x10 end
			when 2 then
				if a_dot_x = 0 then Result := 0x04 else Result := 0x20 end
			when 3 then
				if a_dot_x = 0 then Result := 0x40 else Result := 0x80 end
			end
		ensure
			valid_mask: Result >= 1 and Result <= 128
		end

invariant
	cells_attached: cells /= Void
	cells_size: cells.count = char_width * char_height
	width_positive: char_width > 0
	height_positive: char_height > 0

end
