note
	description: "[
		Renders line charts in ASCII or high-resolution Braille mode.
		Supports multiple data series, axis labels, and titles.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	LINE_CHART_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create line chart renderer with defaults.
		do
			create output.make_empty
			create series_list.make (4)
			create series_names.make (4)
			width := Default_width
			height := Default_height
			use_braille := True
			show_axes := True
			show_legend := True
			create title.make_empty
			create x_label.make_empty
			create y_label.make_empty
		ensure
			output_empty: output.is_empty
			default_size: width = Default_width and height = Default_height
			braille_default: use_braille
		end

feature -- Access

	output: STRING_32
			-- Rendered output.

	as_string: STRING_32
			-- Get rendered chart as string.
		do
			Result := output.twin
		ensure
			result_attached: Result /= Void
		end

	as_string_8: STRING
			-- Get rendered chart as UTF-8 string.
		do
			Result := output.to_string_8
		ensure
			result_attached: Result /= Void
		end

feature -- Settings

	width: INTEGER
			-- Chart width in characters.

	height: INTEGER
			-- Chart height in characters.

	use_braille: BOOLEAN
			-- Use high-resolution braille mode?

	show_axes: BOOLEAN
			-- Show X and Y axes?

	show_legend: BOOLEAN
			-- Show legend for multiple series?

	title: STRING_32
			-- Chart title.

	x_label: STRING_32
			-- X-axis label.

	y_label: STRING_32
			-- Y-axis label.

	set_size (a_width, a_height: INTEGER)
			-- Set chart dimensions.
		require
			width_positive: a_width > 0
			height_positive: a_height > 0
		do
			width := a_width
			height := a_height
		ensure
			width_set: width = a_width
			height_set: height = a_height
		end

	set_use_braille (a_use: BOOLEAN)
			-- Set braille mode.
		do
			use_braille := a_use
		ensure
			set: use_braille = a_use
		end

	set_show_axes (a_show: BOOLEAN)
			-- Set axes visibility.
		do
			show_axes := a_show
		ensure
			set: show_axes = a_show
		end

	set_show_legend (a_show: BOOLEAN)
			-- Set legend visibility.
		do
			show_legend := a_show
		ensure
			set: show_legend = a_show
		end

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set chart title.
		do
			create title.make_from_string_general (a_title)
		ensure
			set: title.same_string_general (a_title)
		end

	set_x_label (a_label: READABLE_STRING_GENERAL)
			-- Set X-axis label.
		do
			create x_label.make_from_string_general (a_label)
		end

	set_y_label (a_label: READABLE_STRING_GENERAL)
			-- Set Y-axis label.
		do
			create y_label.make_from_string_general (a_label)
		end

feature -- Status report

	is_rendered: BOOLEAN
			-- Has chart been rendered?
		do
			Result := not output.is_empty
		end

	series_count: INTEGER
			-- Number of data series.
		do
			Result := series_list.count
		end

feature -- Data management

	add_series (a_name: READABLE_STRING_GENERAL; a_values: ARRAYED_LIST [REAL_64])
			-- Add a data series.
		require
			name_not_empty: not a_name.is_empty
			values_attached: a_values /= Void
		do
			series_list.extend (a_values)
			series_names.extend (a_name.to_string_32)
		ensure
			series_added: series_count = old series_count + 1
		end

	clear_series
			-- Remove all data series.
		do
			series_list.wipe_out
			series_names.wipe_out
		ensure
			cleared: series_count = 0
		end

feature -- Rendering

	render
			-- Render all series to output.
		do
			output.wipe_out
			if series_list.is_empty then
				-- Nothing to render
			else
				if use_braille then
					render_braille
				else
					render_ascii
				end
			end
		end

	render_single (a_values: ARRAYED_LIST [REAL_64])
			-- Convenience: render a single series.
		require
			values_attached: a_values /= Void
		do
			clear_series
			add_series ("data", a_values)
			render
		end

feature {NONE} -- Braille rendering

	render_braille
			-- Render using high-resolution braille.
		local
			l_canvas: BRAILLE_CANVAS
			l_min, l_max, l_range: REAL_64
			l_dot_width, l_dot_height: INTEGER
			l_x_scale, l_y_scale: REAL_64
			l_series: ARRAYED_LIST [REAL_64]
			l_prev_x, l_prev_y, l_curr_x, l_curr_y: INTEGER
			l_i, l_series_idx: INTEGER
			l_value: REAL_64
			l_max_count: INTEGER
		do
			-- Create canvas
			create l_canvas.make (width, height)
			l_dot_width := l_canvas.dot_width
			l_dot_height := l_canvas.dot_height

			-- Find global min/max across all series
			find_min_max

			l_min := global_min
			l_max := global_max
			l_range := l_max - l_min
			if l_range = 0.0 then l_range := 1.0 end

			-- Find max data points
			l_max_count := 0
			across series_list as s loop
				if s.count > l_max_count then l_max_count := s.count end
			end

			-- Calculate scales
			l_x_scale := (l_dot_width - 1).to_double / (l_max_count - 1).max (1).to_double
			l_y_scale := (l_dot_height - 1).to_double / l_range

			-- Draw each series
			from l_series_idx := 1 until l_series_idx > series_list.count loop
				l_series := series_list.i_th (l_series_idx)

				if l_series.count > 0 then
					-- First point
					l_value := l_series.first
					l_prev_x := 0
					l_prev_y := l_dot_height - 1 - ((l_value - l_min) * l_y_scale).rounded.max (0).min (l_dot_height - 1)
					l_canvas.draw_point (l_prev_x, l_prev_y)

					-- Remaining points with lines
					from l_i := 2 until l_i > l_series.count loop
						l_value := l_series.i_th (l_i)
						l_curr_x := ((l_i - 1).to_double * l_x_scale).rounded.max (0).min (l_dot_width - 1)
						l_curr_y := l_dot_height - 1 - ((l_value - l_min) * l_y_scale).rounded.max (0).min (l_dot_height - 1)
						l_canvas.draw_line (l_prev_x, l_prev_y, l_curr_x, l_curr_y)
						l_prev_x := l_curr_x
						l_prev_y := l_curr_y
						l_i := l_i + 1
					end
				end

				l_series_idx := l_series_idx + 1
			end

			-- Build output with optional decorations
			if not title.is_empty then
				output.append (title)
				output.append_character ('%N')
			end

			if show_axes then
				append_y_axis_label (l_max)
			end

			output.append (l_canvas.as_string)
			output.append_character ('%N')

			if show_axes then
				append_y_axis_label (l_min)
				append_x_axis_markers (l_max_count)
			end

			if show_legend and series_count > 1 then
				append_legend
			end
		end

feature {NONE} -- ASCII rendering

	render_ascii
			-- Render using ASCII characters.
		local
			l_grid: ARRAY2 [CHARACTER]
			l_min, l_max, l_range: REAL_64
			l_x_scale, l_y_scale: REAL_64
			l_series: ARRAYED_LIST [REAL_64]
			l_x, l_y, l_prev_x, l_prev_y: INTEGER
			l_i, l_series_idx, l_max_count: INTEGER
			l_value: REAL_64
			l_row, l_col: INTEGER
			l_marker: CHARACTER
		do
			create l_grid.make_filled (' ', height, width)

			-- Find global min/max
			find_min_max
			l_min := global_min
			l_max := global_max
			l_range := l_max - l_min
			if l_range = 0.0 then l_range := 1.0 end

			-- Find max data points
			l_max_count := 0
			across series_list as s loop
				if s.count > l_max_count then l_max_count := s.count end
			end

			-- Calculate scales
			l_x_scale := (width - 1).to_double / (l_max_count - 1).max (1).to_double
			l_y_scale := (height - 1).to_double / l_range

			-- Draw each series with different markers
			from l_series_idx := 1 until l_series_idx > series_list.count loop
				l_series := series_list.i_th (l_series_idx)
				l_marker := marker_for_series (l_series_idx)

				if l_series.count > 0 then
					l_prev_x := -1
					l_prev_y := -1

					from l_i := 1 until l_i > l_series.count loop
						l_value := l_series.i_th (l_i)
						l_x := ((l_i - 1).to_double * l_x_scale).rounded.max (0).min (width - 1)
						l_y := height - ((l_value - l_min) * l_y_scale).rounded.max (0).min (height - 1)
						l_y := l_y.max (1).min (height)

						-- Draw connecting line in ASCII if previous point exists
						if l_prev_x >= 0 then
							draw_ascii_line (l_grid, l_prev_x, l_prev_y, l_x, l_y, l_marker)
						end

						l_grid.put (l_marker, l_y, l_x + 1)
						l_prev_x := l_x
						l_prev_y := l_y
						l_i := l_i + 1
					end
				end

				l_series_idx := l_series_idx + 1
			end

			-- Build output
			if not title.is_empty then
				output.append (title)
				output.append_character ('%N')
			end

			from l_row := 1 until l_row > height loop
				from l_col := 1 until l_col > width loop
					output.append_character (l_grid.item (l_row, l_col))
					l_col := l_col + 1
				end
				output.append_character ('%N')
				l_row := l_row + 1
			end

			if show_legend and series_count > 1 then
				append_legend
			end
		end

	draw_ascii_line (a_grid: ARRAY2 [CHARACTER]; a_x1, a_y1, a_x2, a_y2: INTEGER; a_marker: CHARACTER)
			-- Draw ASCII line between points.
		local
			l_dx, l_dy, l_steps, l_i: INTEGER
			l_x_inc, l_y_inc: REAL_64
			l_x, l_y: REAL_64
			l_grid_x, l_grid_y: INTEGER
		do
			l_dx := a_x2 - a_x1
			l_dy := a_y2 - a_y1
			l_steps := l_dx.abs.max (l_dy.abs)

			if l_steps > 0 then
				l_x_inc := l_dx.to_double / l_steps.to_double
				l_y_inc := l_dy.to_double / l_steps.to_double
				l_x := a_x1.to_double
				l_y := a_y1.to_double

				from l_i := 0 until l_i > l_steps loop
					l_grid_x := l_x.rounded.max (0).min (width - 1) + 1
					l_grid_y := l_y.rounded.max (1).min (height)
					if l_grid_x >= 1 and l_grid_x <= a_grid.width and l_grid_y >= 1 and l_grid_y <= a_grid.height then
						if a_grid.item (l_grid_y, l_grid_x) = ' ' then
							a_grid.put ('.', l_grid_y, l_grid_x)
						end
					end
					l_x := l_x + l_x_inc
					l_y := l_y + l_y_inc
					l_i := l_i + 1
				end
			end
		end

feature {NONE} -- Helper

	series_list: ARRAYED_LIST [ARRAYED_LIST [REAL_64]]
			-- List of data series.

	series_names: ARRAYED_LIST [STRING_32]
			-- Names for each series.

	global_min: REAL_64
			-- Minimum value across all series.

	global_max: REAL_64
			-- Maximum value across all series.

	Markers: STRING = "*+ox#@"
			-- Marker characters for different series.

	marker_for_series (a_index: INTEGER): CHARACTER
			-- Get marker character for series at index.
		require
			index_positive: a_index > 0
		do
			Result := Markers [((a_index - 1) \\ Markers.count) + 1]
		end

	find_min_max
			-- Calculate global_min and global_max.
		local
			l_first: BOOLEAN
		do
			l_first := True
			global_min := 0.0
			global_max := 0.0

			across series_list as s loop
				across s as v loop
					if l_first then
						global_min := v
						global_max := v
						l_first := False
					else
						if v < global_min then global_min := v end
						if v > global_max then global_max := v end
					end
				end
			end
		end

	append_y_axis_label (a_value: REAL_64)
			-- Append Y-axis value label.
		local
			l_str: STRING
		do
			l_str := a_value.out
			if l_str.count > 8 then
				l_str := l_str.substring (1, 8)
			end
			output.append_string_general (l_str)
			output.append (" ")
			output.append_character ((0x2502).to_character_32)  -- Box drawing vertical
			output.append_character ('%N')
		end

	append_x_axis_markers (a_count: INTEGER)
			-- Append X-axis markers.
		local
			l_i: INTEGER
		do
			output.append ("    ")
			output.append_character ((0x2514).to_character_32)  -- Box drawing corner
			from l_i := 1 until l_i > width - 2 loop
				output.append_character ((0x2500).to_character_32)  -- Box drawing horizontal
				l_i := l_i + 1
			end
			output.append_character ((0x2192).to_character_32)  -- Arrow right
			if not x_label.is_empty then
				output.append (" ")
				output.append (x_label)
			end
			output.append_character ('%N')
		end

	append_legend
			-- Append legend for multiple series.
		local
			l_i: INTEGER
		do
			output.append_character ('%N')
			from l_i := 1 until l_i > series_names.count loop
				output.append_character (marker_for_series (l_i))
				output.append (" ")
				output.append (series_names.i_th (l_i))
				if l_i < series_names.count then
					output.append ("  ")
				end
				l_i := l_i + 1
			end
			output.append_character ('%N')
		end

feature -- Constants

	Default_width: INTEGER = 60
			-- Default chart width.

	Default_height: INTEGER = 15
			-- Default chart height.

invariant
	output_attached: output /= Void
	series_list_attached: series_list /= Void
	series_names_attached: series_names /= Void
	series_sync: series_list.count = series_names.count
	width_positive: width > 0
	height_positive: height > 0

end
