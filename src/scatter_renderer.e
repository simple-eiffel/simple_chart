note
	description: "[
		Renders X-Y scatter plots in ASCII or high-resolution Braille mode.
		Supports multiple data series with different point markers.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	SCATTER_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create scatter plot renderer with defaults.
		do
			create output.make_empty
			create series_x.make (4)
			create series_y.make (4)
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
			Result := series_x.count
		end

feature -- Data management

	add_series (a_name: READABLE_STRING_GENERAL; a_x_values, a_y_values: ARRAYED_LIST [REAL_64])
			-- Add a data series with X and Y coordinates.
		require
			name_not_empty: not a_name.is_empty
			x_values_attached: a_x_values /= Void
			y_values_attached: a_y_values /= Void
			same_count: a_x_values.count = a_y_values.count
		do
			series_x.extend (a_x_values)
			series_y.extend (a_y_values)
			series_names.extend (a_name.to_string_32)
		ensure
			series_added: series_count = old series_count + 1
		end

	add_points (a_name: READABLE_STRING_GENERAL; a_points: ARRAYED_LIST [TUPLE [x, y: REAL_64]])
			-- Add series from list of (x, y) tuples.
		require
			name_not_empty: not a_name.is_empty
			points_attached: a_points /= Void
		local
			l_x, l_y: ARRAYED_LIST [REAL_64]
			l_point: TUPLE [x, y: REAL_64]
		do
			create l_x.make (a_points.count)
			create l_y.make (a_points.count)
			across a_points as p loop
				l_point := p
				l_x.extend (l_point.x)
				l_y.extend (l_point.y)
			end
			add_series (a_name, l_x, l_y)
		end

	clear_series
			-- Remove all data series.
		do
			series_x.wipe_out
			series_y.wipe_out
			series_names.wipe_out
		ensure
			cleared: series_count = 0
		end

feature -- Rendering

	render
			-- Render all series to output.
		do
			output.wipe_out
			if series_x.is_empty then
				-- Nothing to render
			else
				find_bounds
				if use_braille then
					render_braille
				else
					render_ascii
				end
			end
		end

	render_xy (a_x_values, a_y_values: ARRAYED_LIST [REAL_64])
			-- Convenience: render a single X-Y series.
		require
			x_attached: a_x_values /= Void
			y_attached: a_y_values /= Void
			same_count: a_x_values.count = a_y_values.count
		do
			clear_series
			add_series ("data", a_x_values, a_y_values)
			render
		end

feature {NONE} -- Braille rendering

	render_braille
			-- Render using high-resolution braille.
		local
			l_canvas: BRAILLE_CANVAS
			l_dot_width, l_dot_height: INTEGER
			l_x_scale, l_y_scale: REAL_64
			l_xs, l_ys: ARRAYED_LIST [REAL_64]
			l_px, l_py: INTEGER
			l_i, l_series_idx: INTEGER
		do
			create l_canvas.make (width, height)
			l_dot_width := l_canvas.dot_width
			l_dot_height := l_canvas.dot_height

			-- Calculate scales
			if x_range > 0.0 then
				l_x_scale := (l_dot_width - 1).to_double / x_range
			else
				l_x_scale := 1.0
			end
			if y_range > 0.0 then
				l_y_scale := (l_dot_height - 1).to_double / y_range
			else
				l_y_scale := 1.0
			end

			-- Draw each series
			from l_series_idx := 1 until l_series_idx > series_x.count loop
				l_xs := series_x.i_th (l_series_idx)
				l_ys := series_y.i_th (l_series_idx)

				from l_i := 1 until l_i > l_xs.count loop
					l_px := ((l_xs.i_th (l_i) - x_min) * l_x_scale).rounded.max (0).min (l_dot_width - 1)
					l_py := l_dot_height - 1 - ((l_ys.i_th (l_i) - y_min) * l_y_scale).rounded.max (0).min (l_dot_height - 1)
					-- Draw point with small cross for visibility
					l_canvas.draw_point (l_px, l_py)
					l_canvas.draw_point (l_px - 1, l_py)
					l_canvas.draw_point (l_px + 1, l_py)
					l_canvas.draw_point (l_px, l_py - 1)
					l_canvas.draw_point (l_px, l_py + 1)
					l_i := l_i + 1
				end

				l_series_idx := l_series_idx + 1
			end

			-- Build output
			if not title.is_empty then
				output.append (title)
				output.append_character ('%N')
			end

			output.append (l_canvas.as_string)
			output.append_character ('%N')

			if show_axes then
				append_axis_info
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
			l_xs, l_ys: ARRAYED_LIST [REAL_64]
			l_px, l_py: INTEGER
			l_i, l_series_idx: INTEGER
			l_x_scale, l_y_scale: REAL_64
			l_row, l_col: INTEGER
			l_marker: CHARACTER
		do
			create l_grid.make_filled (' ', height, width)

			-- Calculate scales
			if x_range > 0.0 then
				l_x_scale := (width - 1).to_double / x_range
			else
				l_x_scale := 1.0
			end
			if y_range > 0.0 then
				l_y_scale := (height - 1).to_double / y_range
			else
				l_y_scale := 1.0
			end

			-- Draw each series
			from l_series_idx := 1 until l_series_idx > series_x.count loop
				l_xs := series_x.i_th (l_series_idx)
				l_ys := series_y.i_th (l_series_idx)
				l_marker := marker_for_series (l_series_idx)

				from l_i := 1 until l_i > l_xs.count loop
					l_px := ((l_xs.i_th (l_i) - x_min) * l_x_scale).rounded.max (0).min (width - 1) + 1
					l_py := height - ((l_ys.i_th (l_i) - y_min) * l_y_scale).rounded.max (0).min (height - 1)
					l_py := l_py.max (1).min (height)
					l_grid.put (l_marker, l_py, l_px)
					l_i := l_i + 1
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

			if show_axes then
				append_axis_info
			end

			if show_legend and series_count > 1 then
				append_legend
			end
		end

feature {NONE} -- Implementation

	series_x: ARRAYED_LIST [ARRAYED_LIST [REAL_64]]
			-- X values for each series.

	series_y: ARRAYED_LIST [ARRAYED_LIST [REAL_64]]
			-- Y values for each series.

	series_names: ARRAYED_LIST [STRING_32]
			-- Names for each series.

	x_min, x_max, y_min, y_max: REAL_64
			-- Bounds across all data.

	x_range: REAL_64
			-- X range (max - min).
		do
			Result := x_max - x_min
		end

	y_range: REAL_64
			-- Y range (max - min).
		do
			Result := y_max - y_min
		end

	Markers: STRING = "*+ox#@"
			-- Marker characters for different series.

	marker_for_series (a_index: INTEGER): CHARACTER
			-- Get marker character for series at index.
		require
			index_positive: a_index > 0
		do
			Result := Markers [((a_index - 1) \\ Markers.count) + 1]
		end

	find_bounds
			-- Calculate x_min, x_max, y_min, y_max.
		local
			l_first: BOOLEAN
		do
			l_first := True
			x_min := 0.0; x_max := 0.0
			y_min := 0.0; y_max := 0.0

			across series_x as sx loop
				across sx as v loop
					if l_first then
						x_min := v; x_max := v
						l_first := False
					else
						if v < x_min then x_min := v end
						if v > x_max then x_max := v end
					end
				end
			end

			l_first := True
			across series_y as sy loop
				across sy as v loop
					if l_first then
						y_min := v; y_max := v
						l_first := False
					else
						if v < y_min then y_min := v end
						if v > y_max then y_max := v end
					end
				end
			end
		end

	append_axis_info
			-- Append axis range info.
		do
			output.append ("X: [")
			output.append (format_num (x_min))
			output.append (", ")
			output.append (format_num (x_max))
			output.append ("]")
			if not x_label.is_empty then
				output.append (" ")
				output.append (x_label)
			end
			output.append ("  Y: [")
			output.append (format_num (y_min))
			output.append (", ")
			output.append (format_num (y_max))
			output.append ("]")
			if not y_label.is_empty then
				output.append (" ")
				output.append (y_label)
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

	format_num (a_value: REAL_64): STRING_32
			-- Format number compactly.
		local
			l_str: STRING
		do
			if a_value = a_value.truncated_to_integer.to_double then
				create Result.make_from_string (a_value.truncated_to_integer.out)
			else
				l_str := a_value.out
				if l_str.count > 8 then
					l_str := l_str.substring (1, 8)
				end
				create Result.make_from_string (l_str)
			end
		end

feature -- Constants

	Default_width: INTEGER = 60
			-- Default chart width.

	Default_height: INTEGER = 15
			-- Default chart height.

invariant
	output_attached: output /= Void
	series_sync: series_x.count = series_y.count and series_x.count = series_names.count
	width_positive: width > 0
	height_positive: height > 0

end
