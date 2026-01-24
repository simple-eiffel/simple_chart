note
	description: "[
		Renders charts as SVG (Scalable Vector Graphics).
		SVG is XML-based, viewable in browsers, and scalable.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	SVG_CHART_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create SVG renderer with defaults.
		do
			width := 600
			height := 400
			create output.make_empty
			create title.make_empty
		end

feature -- Access

	output: STRING
			-- Generated SVG content.

	width: INTEGER
			-- SVG width in pixels.

	height: INTEGER
			-- SVG height in pixels.

	title: STRING
			-- Chart title.

feature -- Settings

	set_size (a_width, a_height: INTEGER)
			-- Set SVG dimensions.
		require
			width_positive: a_width > 0
			height_positive: a_height > 0
		do
			width := a_width
			height := a_height
		end

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set chart title.
		do
			title := a_title.to_string_8
		end

feature -- Bar Chart

	render_bar_chart (a_labels: ARRAYED_LIST [STRING]; a_values: ARRAYED_LIST [REAL_64])
			-- Render horizontal bar chart as SVG.
		require
			labels_attached: a_labels /= Void
			values_attached: a_values /= Void
			same_count: a_labels.count = a_values.count
		local
			l_max: REAL_64
			l_bar_height, l_y, l_bar_width: INTEGER
			l_i: INTEGER
			l_margin: INTEGER
		do
			output.wipe_out
			l_margin := 80
			l_bar_height := ((height - 60) // a_values.count.max (1)).max (20)

			-- Find max value
			l_max := 0.001
			across a_values as v loop
				if v > l_max then l_max := v end
			end

			start_svg
			add_title_element

			-- Render bars
			l_y := 40
			from l_i := 1 until l_i > a_values.count loop
				l_bar_width := ((a_values.i_th (l_i) / l_max) * (width - l_margin - 20)).truncated_to_integer.max (1)

				-- Bar
				output.append ("  <rect x=%"" + l_margin.out + "%" y=%"" + l_y.out + "%" ")
				output.append ("width=%"" + l_bar_width.out + "%" height=%"" + (l_bar_height - 4).out + "%" ")
				output.append ("fill=%"#4a90d9%" stroke=%"#2c5aa0%" stroke-width=%"1%"/>%N")

				-- Label
				output.append ("  <text x=%"" + (l_margin - 5).out + "%" y=%"" + (l_y + l_bar_height // 2).out + "%" ")
				output.append ("text-anchor=%"end%" font-size=%"12%" fill=%"#333%">")
				output.append (escape_xml (a_labels.i_th (l_i)))
				output.append ("</text>%N")

				-- Value
				output.append ("  <text x=%"" + (l_margin + l_bar_width + 5).out + "%" y=%"" + (l_y + l_bar_height // 2).out + "%" ")
				output.append ("font-size=%"11%" fill=%"#666%">")
				output.append (format_value (a_values.i_th (l_i)))
				output.append ("</text>%N")

				l_y := l_y + l_bar_height
				l_i := l_i + 1
			end

			end_svg
		end

feature -- Line Chart

	render_line_chart (a_values: ARRAYED_LIST [REAL_64])
			-- Render line chart as SVG.
		require
			values_attached: a_values /= Void
			has_values: not a_values.is_empty
		local
			l_min, l_max, l_range: REAL_64
			l_x_step: REAL_64
			l_x, l_y: INTEGER
			l_i: INTEGER
			l_points: STRING
			l_margin_left, l_margin_bottom: INTEGER
			l_chart_width, l_chart_height: INTEGER
		do
			output.wipe_out
			l_margin_left := 50
			l_margin_bottom := 30
			l_chart_width := width - l_margin_left - 20
			l_chart_height := height - 50 - l_margin_bottom

			-- Find range
			l_min := a_values.first
			l_max := a_values.first
			across a_values as v loop
				if v < l_min then l_min := v end
				if v > l_max then l_max := v end
			end
			l_range := (l_max - l_min).max (0.001)

			start_svg
			add_title_element

			-- Axes
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"40%" x2=%"" + l_margin_left.out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"" + (height - l_margin_bottom).out + "%" x2=%"" + (width - 20).out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")

			-- Build polyline points
			create l_points.make (a_values.count * 20)
			l_x_step := l_chart_width / (a_values.count - 1).max (1)

			from l_i := 1 until l_i > a_values.count loop
				l_x := l_margin_left + ((l_i - 1).to_double * l_x_step).truncated_to_integer
				l_y := (height - l_margin_bottom) - ((a_values.i_th (l_i) - l_min) / l_range * l_chart_height).truncated_to_integer
				if l_i > 1 then
					l_points.append (" ")
				end
				l_points.append (l_x.out + "," + l_y.out)
				l_i := l_i + 1
			end

			-- Draw line
			output.append ("  <polyline points=%"" + l_points + "%" fill=%"none%" stroke=%"#4a90d9%" stroke-width=%"2%"/>%N")

			-- Draw points
			from l_i := 1 until l_i > a_values.count loop
				l_x := l_margin_left + ((l_i - 1).to_double * l_x_step).truncated_to_integer
				l_y := (height - l_margin_bottom) - ((a_values.i_th (l_i) - l_min) / l_range * l_chart_height).truncated_to_integer
				output.append ("  <circle cx=%"" + l_x.out + "%" cy=%"" + l_y.out + "%" r=%"3%" fill=%"#2c5aa0%"/>%N")
				l_i := l_i + 1
			end

			-- Y-axis labels
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"45%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_max) + "</text>%N")
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"" + (height - l_margin_bottom).out + "%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_min) + "</text>%N")

			end_svg
		end

feature -- Scatter Plot

	render_scatter (a_x_values, a_y_values: ARRAYED_LIST [REAL_64])
			-- Render scatter plot as SVG.
		require
			x_attached: a_x_values /= Void
			y_attached: a_y_values /= Void
			same_count: a_x_values.count = a_y_values.count
		local
			l_x_min, l_x_max, l_y_min, l_y_max: REAL_64
			l_x_range, l_y_range: REAL_64
			l_x, l_y: INTEGER
			l_i: INTEGER
			l_margin_left, l_margin_bottom: INTEGER
			l_chart_width, l_chart_height: INTEGER
		do
			output.wipe_out
			l_margin_left := 50
			l_margin_bottom := 30
			l_chart_width := width - l_margin_left - 20
			l_chart_height := height - 50 - l_margin_bottom

			-- Find ranges
			l_x_min := a_x_values.first
			l_x_max := a_x_values.first
			l_y_min := a_y_values.first
			l_y_max := a_y_values.first
			across a_x_values as v loop
				if v < l_x_min then l_x_min := v end
				if v > l_x_max then l_x_max := v end
			end
			across a_y_values as v loop
				if v < l_y_min then l_y_min := v end
				if v > l_y_max then l_y_max := v end
			end
			l_x_range := (l_x_max - l_x_min).max (0.001)
			l_y_range := (l_y_max - l_y_min).max (0.001)

			start_svg
			add_title_element

			-- Axes
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"40%" x2=%"" + l_margin_left.out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"" + (height - l_margin_bottom).out + "%" x2=%"" + (width - 20).out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")

			-- Draw points
			from l_i := 1 until l_i > a_x_values.count loop
				l_x := l_margin_left + ((a_x_values.i_th (l_i) - l_x_min) / l_x_range * l_chart_width).truncated_to_integer
				l_y := (height - l_margin_bottom) - ((a_y_values.i_th (l_i) - l_y_min) / l_y_range * l_chart_height).truncated_to_integer
				output.append ("  <circle cx=%"" + l_x.out + "%" cy=%"" + l_y.out + "%" r=%"4%" fill=%"#e74c3c%" stroke=%"#c0392b%" stroke-width=%"1%"/>%N")
				l_i := l_i + 1
			end

			-- Axis labels
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"45%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_y_max) + "</text>%N")
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"" + (height - l_margin_bottom).out + "%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_y_min) + "</text>%N")
			output.append ("  <text x=%"" + l_margin_left.out + "%" y=%"" + (height - 10).out + "%" font-size=%"10%" fill=%"#666%">" + format_value (l_x_min) + "</text>%N")
			output.append ("  <text x=%"" + (width - 20).out + "%" y=%"" + (height - 10).out + "%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_x_max) + "</text>%N")

			end_svg
		end

feature -- Histogram

	render_histogram (a_values: ARRAYED_LIST [REAL_64]; a_bin_count: INTEGER)
			-- Render histogram as SVG.
		require
			values_attached: a_values /= Void
			bins_positive: a_bin_count > 0
		local
			l_min, l_max, l_range, l_bin_width: REAL_64
			l_bins: ARRAY [INTEGER]
			l_max_count, l_bin_idx: INTEGER
			l_i, l_x, l_bar_height, l_bar_width: INTEGER
			l_margin_left, l_margin_bottom: INTEGER
			l_chart_width, l_chart_height: INTEGER
		do
			output.wipe_out
			l_margin_left := 50
			l_margin_bottom := 30
			l_chart_width := width - l_margin_left - 20
			l_chart_height := height - 50 - l_margin_bottom

			-- Find range
			l_min := a_values.first
			l_max := a_values.first
			across a_values as v loop
				if v < l_min then l_min := v end
				if v > l_max then l_max := v end
			end
			l_range := (l_max - l_min).max (0.001)
			l_bin_width := l_range / a_bin_count

			-- Count into bins
			create l_bins.make_filled (0, 0, a_bin_count - 1)
			across a_values as v loop
				l_bin_idx := ((v - l_min) / l_bin_width).floor.min (a_bin_count - 1).max (0)
				l_bins [l_bin_idx] := l_bins [l_bin_idx] + 1
			end

			-- Find max count
			l_max_count := 1
			across l_bins as c loop
				if c > l_max_count then l_max_count := c end
			end

			start_svg
			add_title_element

			-- Axes
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"40%" x2=%"" + l_margin_left.out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")
			output.append ("  <line x1=%"" + l_margin_left.out + "%" y1=%"" + (height - l_margin_bottom).out + "%" x2=%"" + (width - 20).out + "%" y2=%"" + (height - l_margin_bottom).out + "%" stroke=%"#333%" stroke-width=%"1%"/>%N")

			-- Draw bars
			l_bar_width := (l_chart_width // a_bin_count).max (1)
			from l_i := 0 until l_i >= a_bin_count loop
				l_x := l_margin_left + l_i * l_bar_width
				l_bar_height := (l_bins [l_i].to_double / l_max_count * l_chart_height).truncated_to_integer
				if l_bar_height > 0 then
					output.append ("  <rect x=%"" + l_x.out + "%" y=%"" + ((height - l_margin_bottom) - l_bar_height).out + "%" ")
					output.append ("width=%"" + (l_bar_width - 1).out + "%" height=%"" + l_bar_height.out + "%" ")
					output.append ("fill=%"#27ae60%" stroke=%"#1e8449%" stroke-width=%"1%"/>%N")
				end
				l_i := l_i + 1
			end

			-- Axis labels
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"45%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + l_max_count.out + "</text>%N")
			output.append ("  <text x=%"" + (l_margin_left - 5).out + "%" y=%"" + (height - l_margin_bottom).out + "%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">0</text>%N")
			output.append ("  <text x=%"" + l_margin_left.out + "%" y=%"" + (height - 10).out + "%" font-size=%"10%" fill=%"#666%">" + format_value (l_min) + "</text>%N")
			output.append ("  <text x=%"" + (width - 20).out + "%" y=%"" + (height - 10).out + "%" text-anchor=%"end%" font-size=%"10%" fill=%"#666%">" + format_value (l_max) + "</text>%N")

			end_svg
		end

feature {NONE} -- Implementation

	start_svg
			-- Write SVG header.
		do
			output.append ("<?xml version=%"1.0%" encoding=%"UTF-8%"?>%N")
			output.append ("<svg xmlns=%"http://www.w3.org/2000/svg%" width=%"" + width.out + "%" height=%"" + height.out + "%" viewBox=%"0 0 " + width.out + " " + height.out + "%">%N")
			output.append ("  <rect width=%"100%%%" height=%"100%%%" fill=%"white%"/>%N")
		end

	end_svg
			-- Write SVG footer.
		do
			output.append ("</svg>%N")
		end

	add_title_element
			-- Add title text if set.
		do
			if not title.is_empty then
				output.append ("  <text x=%"" + (width // 2).out + "%" y=%"25%" text-anchor=%"middle%" font-size=%"16%" font-weight=%"bold%" fill=%"#333%">")
				output.append (escape_xml (title))
				output.append ("</text>%N")
			end
		end

	escape_xml (a_text: STRING): STRING
			-- Escape XML special characters.
		do
			create Result.make_from_string (a_text)
			Result.replace_substring_all ("&", "&amp;")
			Result.replace_substring_all ("<", "&lt;")
			Result.replace_substring_all (">", "&gt;")
			Result.replace_substring_all ("%"", "&quot;")
		end

	format_value (a_value: REAL_64): STRING
			-- Format number for display.
		do
			if a_value = a_value.truncated_to_integer.to_double then
				Result := a_value.truncated_to_integer.out
			else
				Result := a_value.out
				if Result.count > 8 then
					Result := Result.substring (1, 8)
				end
			end
		end

invariant
	output_attached: output /= Void
	width_positive: width > 0
	height_positive: height > 0

end
