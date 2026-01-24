note
	description: "[
		Renders charts to PNG images using simple_cairo.
		Professional quality raster output with anti-aliasing.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	CAIRO_CHART_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create renderer with defaults.
		do
			create cairo.make
			width := 800
			height := 600
			margin := 60
			create title.make_empty
			create last_error.make_empty
		end

feature -- Access

	cairo: SIMPLE_CAIRO
			-- Cairo wrapper.

	width: INTEGER
			-- Image width in pixels.

	height: INTEGER
			-- Image height in pixels.

	margin: INTEGER
			-- Chart margin in pixels.

	title: STRING
			-- Chart title.

	last_error: STRING
			-- Last error message.

feature -- Settings

	set_size (a_width, a_height: INTEGER)
			-- Set image dimensions.
		require
			width_positive: a_width > 0
			height_positive: a_height > 0
		do
			width := a_width
			height := a_height
		end

	set_margin (a_margin: INTEGER)
			-- Set chart margin.
		require
			margin_non_negative: a_margin >= 0
		do
			margin := a_margin
		end

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set chart title.
		do
			title := a_title.to_string_8
		end

feature -- Bar Chart

	render_bar_chart (a_labels: ARRAYED_LIST [STRING]; a_values: ARRAYED_LIST [REAL_64]; a_path: STRING)
			-- Render horizontal bar chart to PNG file.
		require
			labels_attached: a_labels /= Void
			values_attached: a_values /= Void
			same_count: a_labels.count = a_values.count
			path_not_empty: not a_path.is_empty
		local
			l_surface: CAIRO_SURFACE
			l_ctx: CAIRO_CONTEXT
			l_max: REAL_64
			l_bar_height, l_y, l_bar_width: INTEGER
			l_i: INTEGER
			l_chart_width: INTEGER
			l_dummy: CAIRO_CONTEXT
			l_ok: BOOLEAN
		do
			last_error.wipe_out
			l_surface := cairo.create_surface (width, height)
			if l_surface.is_valid then
				l_ctx := cairo.create_context (l_surface)

				-- White background
				l_dummy := l_ctx.set_color_hex (0xFFFFFF)
				l_dummy := l_ctx.fill_rect (0, 0, width.to_real, height.to_real)

				-- Title
				if not title.is_empty then
					l_dummy := l_ctx.set_color_hex (0x333333)
					l_dummy := l_ctx.set_font_size (16.0)
					l_dummy := l_ctx.move_to ((width // 2).to_real, 30.0)
					l_dummy := l_ctx.show_text (title)
				end

				-- Find max value
				l_max := 0.001
				across a_values as v loop
					if v > l_max then l_max := v end
				end

				l_chart_width := width - margin - 20
				l_bar_height := ((height - 80) // a_values.count.max (1)).max (15)

				-- Draw bars
				l_y := 50
				from l_i := 1 until l_i > a_values.count loop
					l_bar_width := ((a_values.i_th (l_i) / l_max) * l_chart_width).truncated_to_integer.max (1)

					-- Bar fill
					l_dummy := l_ctx.set_color_hex (0x4A90D9)
					l_dummy := l_ctx.fill_rect (margin.to_real, l_y.to_real, l_bar_width.to_real, (l_bar_height - 2).to_real)

					-- Bar border
					l_dummy := l_ctx.set_color_hex (0x2C5AA0)
					l_dummy := l_ctx.set_line_width (1.0)
					l_dummy := l_ctx.stroke_rect (margin.to_real, l_y.to_real, l_bar_width.to_real, (l_bar_height - 2).to_real)

					-- Label (left of bar)
					l_dummy := l_ctx.set_color_hex (0x333333)
					l_dummy := l_ctx.set_font_size (11.0)
					l_dummy := l_ctx.move_to (5.0, (l_y + l_bar_height // 2 + 4).to_real)
					l_dummy := l_ctx.show_text (a_labels.i_th (l_i))

					-- Value (right of bar)
					l_dummy := l_ctx.set_color_hex (0x666666)
					l_dummy := l_ctx.move_to ((margin + l_bar_width + 5).to_real, (l_y + l_bar_height // 2 + 4).to_real)
					l_dummy := l_ctx.show_text (format_value (a_values.i_th (l_i)))

					l_y := l_y + l_bar_height
					l_i := l_i + 1
				end

				l_ok := l_surface.write_png (a_path)
				l_ctx.destroy
				l_surface.destroy
				if not l_ok then
					last_error := "Failed to write PNG"
				end
			else
				last_error := "Failed to create Cairo surface"
			end
		end

feature -- Line Chart

	render_line_chart (a_values: ARRAYED_LIST [REAL_64]; a_path: STRING)
			-- Render line chart to PNG file.
		require
			values_attached: a_values /= Void
			has_values: not a_values.is_empty
			path_not_empty: not a_path.is_empty
		local
			l_surface: CAIRO_SURFACE
			l_ctx: CAIRO_CONTEXT
			l_min, l_max, l_range: REAL_64
			l_x_step: REAL_64
			l_x, l_y, l_prev_x, l_prev_y: INTEGER
			l_i: INTEGER
			l_chart_width, l_chart_height: INTEGER
			l_dummy: CAIRO_CONTEXT
			l_ok: BOOLEAN
		do
			last_error.wipe_out
			l_surface := cairo.create_surface (width, height)
			if l_surface.is_valid then
				l_ctx := cairo.create_context (l_surface)

				-- White background
				l_dummy := l_ctx.set_color_hex (0xFFFFFF)
				l_dummy := l_ctx.fill_rect (0, 0, width.to_real, height.to_real)

				-- Title
				if not title.is_empty then
					l_dummy := l_ctx.set_color_hex (0x333333)
					l_dummy := l_ctx.set_font_size (16.0)
					l_dummy := l_ctx.move_to ((width // 2 - 50).to_real, 25.0)
					l_dummy := l_ctx.show_text (title)
				end

				-- Find range
				l_min := a_values.first
				l_max := a_values.first
				across a_values as v loop
					if v < l_min then l_min := v end
					if v > l_max then l_max := v end
				end
				l_range := (l_max - l_min).max (0.001)

				l_chart_width := width - margin - 20
				l_chart_height := height - 80

				-- Draw axes
				l_dummy := l_ctx.set_color_hex (0x333333)
				l_dummy := l_ctx.set_line_width (1.5)
				l_dummy := l_ctx.draw_line (margin.to_real, 50.0, margin.to_real, (height - 30).to_real)
				l_dummy := l_ctx.draw_line (margin.to_real, (height - 30).to_real, (width - 20).to_real, (height - 30).to_real)

				-- Y-axis labels
				l_dummy := l_ctx.set_color_hex (0x666666)
				l_dummy := l_ctx.set_font_size (10.0)
				l_dummy := l_ctx.move_to (5.0, 55.0)
				l_dummy := l_ctx.show_text (format_value (l_max))
				l_dummy := l_ctx.move_to (5.0, (height - 25).to_real)
				l_dummy := l_ctx.show_text (format_value (l_min))

				-- Draw line
				l_x_step := l_chart_width / (a_values.count - 1).max (1)
				l_dummy := l_ctx.set_color_hex (0x4A90D9)
				l_dummy := l_ctx.set_line_width (2.0)

				from l_i := 1 until l_i > a_values.count loop
					l_x := margin + ((l_i - 1).to_double * l_x_step).truncated_to_integer
					l_y := (height - 30) - ((a_values.i_th (l_i) - l_min) / l_range * l_chart_height).truncated_to_integer

					if l_i > 1 then
						l_dummy := l_ctx.draw_line (l_prev_x.to_real, l_prev_y.to_real, l_x.to_real, l_y.to_real)
					end

					l_prev_x := l_x
					l_prev_y := l_y
					l_i := l_i + 1
				end

				-- Draw points
				l_dummy := l_ctx.set_color_hex (0x2C5AA0)
				from l_i := 1 until l_i > a_values.count loop
					l_x := margin + ((l_i - 1).to_double * l_x_step).truncated_to_integer
					l_y := (height - 30) - ((a_values.i_th (l_i) - l_min) / l_range * l_chart_height).truncated_to_integer
					l_dummy := l_ctx.fill_circle (l_x.to_real, l_y.to_real, 4.0)
					l_i := l_i + 1
				end

				l_ok := l_surface.write_png (a_path)
				l_ctx.destroy
				l_surface.destroy
				if not l_ok then
					last_error := "Failed to write PNG"
				end
			else
				last_error := "Failed to create Cairo surface"
			end
		end

feature -- Scatter Plot

	render_scatter (a_x_values, a_y_values: ARRAYED_LIST [REAL_64]; a_path: STRING)
			-- Render scatter plot to PNG file.
		require
			x_attached: a_x_values /= Void
			y_attached: a_y_values /= Void
			same_count: a_x_values.count = a_y_values.count
			path_not_empty: not a_path.is_empty
		local
			l_surface: CAIRO_SURFACE
			l_ctx: CAIRO_CONTEXT
			l_x_min, l_x_max, l_y_min, l_y_max: REAL_64
			l_x_range, l_y_range: REAL_64
			l_x, l_y: INTEGER
			l_i: INTEGER
			l_chart_width, l_chart_height: INTEGER
			l_dummy: CAIRO_CONTEXT
			l_ok: BOOLEAN
		do
			last_error.wipe_out
			l_surface := cairo.create_surface (width, height)
			if l_surface.is_valid then
				l_ctx := cairo.create_context (l_surface)

				-- White background
				l_dummy := l_ctx.set_color_hex (0xFFFFFF)
				l_dummy := l_ctx.fill_rect (0, 0, width.to_real, height.to_real)

				-- Title
				if not title.is_empty then
					l_dummy := l_ctx.set_color_hex (0x333333)
					l_dummy := l_ctx.set_font_size (16.0)
					l_dummy := l_ctx.move_to ((width // 2 - 80).to_real, 25.0)
					l_dummy := l_ctx.show_text (title)
				end

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

				l_chart_width := width - margin - 20
				l_chart_height := height - 80

				-- Draw axes
				l_dummy := l_ctx.set_color_hex (0x333333)
				l_dummy := l_ctx.set_line_width (1.5)
				l_dummy := l_ctx.draw_line (margin.to_real, 50.0, margin.to_real, (height - 30).to_real)
				l_dummy := l_ctx.draw_line (margin.to_real, (height - 30).to_real, (width - 20).to_real, (height - 30).to_real)

				-- Axis labels
				l_dummy := l_ctx.set_color_hex (0x666666)
				l_dummy := l_ctx.set_font_size (10.0)
				l_dummy := l_ctx.move_to (5.0, 55.0)
				l_dummy := l_ctx.show_text (format_value (l_y_max))
				l_dummy := l_ctx.move_to (5.0, (height - 25).to_real)
				l_dummy := l_ctx.show_text (format_value (l_y_min))
				l_dummy := l_ctx.move_to (margin.to_real, (height - 10).to_real)
				l_dummy := l_ctx.show_text (format_value (l_x_min))
				l_dummy := l_ctx.move_to ((width - 50).to_real, (height - 10).to_real)
				l_dummy := l_ctx.show_text (format_value (l_x_max))

				-- Draw points
				l_dummy := l_ctx.set_color_hex (0xE74C3C)
				from l_i := 1 until l_i > a_x_values.count loop
					l_x := margin + ((a_x_values.i_th (l_i) - l_x_min) / l_x_range * l_chart_width).truncated_to_integer
					l_y := (height - 30) - ((a_y_values.i_th (l_i) - l_y_min) / l_y_range * l_chart_height).truncated_to_integer
					l_dummy := l_ctx.fill_circle (l_x.to_real, l_y.to_real, 5.0)
					l_i := l_i + 1
				end

				l_ok := l_surface.write_png (a_path)
				l_ctx.destroy
				l_surface.destroy
				if not l_ok then
					last_error := "Failed to write PNG"
				end
			else
				last_error := "Failed to create Cairo surface"
			end
		end

feature -- Histogram

	render_histogram (a_values: ARRAYED_LIST [REAL_64]; a_bin_count: INTEGER; a_path: STRING)
			-- Render histogram to PNG file.
		require
			values_attached: a_values /= Void
			bins_positive: a_bin_count > 0
			path_not_empty: not a_path.is_empty
		local
			l_surface: CAIRO_SURFACE
			l_ctx: CAIRO_CONTEXT
			l_min, l_max, l_range, l_bin_width: REAL_64
			l_bins: ARRAY [INTEGER]
			l_max_count, l_bin_idx: INTEGER
			l_i, l_x, l_bar_height, l_bar_w: INTEGER
			l_chart_width, l_chart_height: INTEGER
			l_dummy: CAIRO_CONTEXT
			l_ok: BOOLEAN
		do
			last_error.wipe_out
			l_surface := cairo.create_surface (width, height)
			if l_surface.is_valid then
				l_ctx := cairo.create_context (l_surface)

				-- White background
				l_dummy := l_ctx.set_color_hex (0xFFFFFF)
				l_dummy := l_ctx.fill_rect (0, 0, width.to_real, height.to_real)

				-- Title
				if not title.is_empty then
					l_dummy := l_ctx.set_color_hex (0x333333)
					l_dummy := l_ctx.set_font_size (16.0)
					l_dummy := l_ctx.move_to ((width // 2 - 80).to_real, 25.0)
					l_dummy := l_ctx.show_text (title)
				end

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

				l_chart_width := width - margin - 20
				l_chart_height := height - 80
				l_bar_w := (l_chart_width // a_bin_count).max (1)

				-- Draw axes
				l_dummy := l_ctx.set_color_hex (0x333333)
				l_dummy := l_ctx.set_line_width (1.5)
				l_dummy := l_ctx.draw_line (margin.to_real, 50.0, margin.to_real, (height - 30).to_real)
				l_dummy := l_ctx.draw_line (margin.to_real, (height - 30).to_real, (width - 20).to_real, (height - 30).to_real)

				-- Y-axis labels
				l_dummy := l_ctx.set_color_hex (0x666666)
				l_dummy := l_ctx.set_font_size (10.0)
				l_dummy := l_ctx.move_to (5.0, 55.0)
				l_dummy := l_ctx.show_text (l_max_count.out)
				l_dummy := l_ctx.move_to (5.0, (height - 25).to_real)
				l_dummy := l_ctx.show_text ("0")

				-- X-axis labels
				l_dummy := l_ctx.move_to (margin.to_real, (height - 10).to_real)
				l_dummy := l_ctx.show_text (format_value (l_min))
				l_dummy := l_ctx.move_to ((width - 50).to_real, (height - 10).to_real)
				l_dummy := l_ctx.show_text (format_value (l_max))

				-- Draw bars
				from l_i := 0 until l_i >= a_bin_count loop
					l_x := margin + l_i * l_bar_w
					l_bar_height := (l_bins [l_i].to_double / l_max_count * l_chart_height).truncated_to_integer
					if l_bar_height > 0 then
						l_dummy := l_ctx.set_color_hex (0x27AE60)
						l_dummy := l_ctx.fill_rect (l_x.to_real, ((height - 30) - l_bar_height).to_real, (l_bar_w - 1).to_real, l_bar_height.to_real)
						l_dummy := l_ctx.set_color_hex (0x1E8449)
						l_dummy := l_ctx.set_line_width (1.0)
						l_dummy := l_ctx.stroke_rect (l_x.to_real, ((height - 30) - l_bar_height).to_real, (l_bar_w - 1).to_real, l_bar_height.to_real)
					end
					l_i := l_i + 1
				end

				l_ok := l_surface.write_png (a_path)
				l_ctx.destroy
				l_surface.destroy
				if not l_ok then
					last_error := "Failed to write PNG"
				end
			else
				last_error := "Failed to create Cairo surface"
			end
		end

feature {NONE} -- Implementation

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
	cairo_attached: cairo /= Void
	width_positive: width > 0
	height_positive: height > 0

end
