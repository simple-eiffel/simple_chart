note
	description: "[
		Main facade for charting library.
		Provides one-liner API for common chart types and data loading.

		Quick examples:
			chart.sparkline ([10, 20, 15, 30, 25])  -- Inline mini-chart
			chart.bar_chart (labels, values)        -- Horizontal bars
			chart.line_chart (values)               -- Line graph
			chart.scatter (x_values, y_values)      -- X-Y scatter plot
			chart.histogram (values)                -- Frequency distribution
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	SIMPLE_CHART

create
	make

feature {NONE} -- Initialization

	make
			-- Create chart facade.
		do
			create csv_loader.make
			create json_loader.make
			create bar_renderer.make
			create table_renderer.make
			create line_renderer.make
			create scatter_renderer.make
			create histogram_renderer.make
			create sparkline_renderer.make
			create last_error.make_empty
		ensure
			components_created: csv_loader /= Void and bar_renderer /= Void
		end

feature -- Access (Loaders)

	csv_loader: CSV_DATA_LOADER
			-- CSV data loader.

	json_loader: JSON_DATA_LOADER
			-- JSON data loader.

feature -- Access (Renderers)

	bar_renderer: BAR_CHART_RENDERER
			-- Bar chart renderer.

	table_renderer: TABLE_RENDERER
			-- Table renderer.

	line_renderer: LINE_CHART_RENDERER
			-- Line chart renderer.

	scatter_renderer: SCATTER_RENDERER
			-- Scatter plot renderer.

	histogram_renderer: HISTOGRAM_RENDERER
			-- Histogram renderer.

	sparkline_renderer: SPARKLINE_RENDERER
			-- Sparkline renderer.

feature -- Status report

	has_data: BOOLEAN
			-- Is data loaded (from CSV or JSON)?
		do
			Result := csv_loader.has_data or json_loader.has_data
		end

	last_error: STRING
			-- Last error message if any.

feature -- Data loading

	load_csv (a_path: READABLE_STRING_GENERAL)
			-- Load CSV data from file at `a_path`.
		require
			path_not_empty: not a_path.is_empty
		do
			last_error.wipe_out
			csv_loader.load_from_file (a_path)
			if not csv_loader.has_data then
				last_error := "Failed to load CSV from file: " + a_path.to_string_8
			end
		ensure
			data_or_error: csv_loader.has_data or not last_error.is_empty
		end

	load_csv_string (a_content: READABLE_STRING_GENERAL)
			-- Load CSV data from string `a_content`.
		require
			content_not_empty: not a_content.is_empty
		do
			last_error.wipe_out
			csv_loader.load_from_string (a_content)
			if not csv_loader.has_data then
				last_error := "Failed to parse CSV content"
			end
		end

	load_json (a_path: READABLE_STRING_GENERAL)
			-- Load JSON data from file at `a_path`.
		require
			path_not_empty: not a_path.is_empty
		do
			last_error.wipe_out
			json_loader.load_from_file (a_path)
			if not json_loader.has_data then
				last_error := json_loader.last_error.twin
			end
		end

	load_json_string (a_content: READABLE_STRING_GENERAL)
			-- Load JSON data from string `a_content`.
		require
			content_not_empty: not a_content.is_empty
		do
			last_error.wipe_out
			json_loader.load_from_string (a_content)
			if not json_loader.has_data then
				last_error := json_loader.last_error.twin
			end
		end

feature -- One-liner Chart API

	sparkline (a_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- Render compact inline sparkline.
			-- Example: chart.sparkline ([10, 20, 15, 30, 25]) => "▂▅▃█▆"
		require
			values_attached: a_values /= Void
		do
			sparkline_renderer.render (a_values)
			Result := sparkline_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	bar_chart (a_labels: ARRAYED_LIST [STRING]; a_values: ARRAYED_LIST [REAL_64]): STRING
			-- Render horizontal bar chart.
		require
			labels_attached: a_labels /= Void
			values_attached: a_values /= Void
			same_count: a_labels.count = a_values.count
		do
			bar_renderer.render (a_labels, a_values)
			Result := bar_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	line_chart (a_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- Render line chart (braille mode by default).
		require
			values_attached: a_values /= Void
		do
			line_renderer.render_single (a_values)
			Result := line_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	line_chart_ascii (a_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- Render line chart in ASCII mode.
		require
			values_attached: a_values /= Void
		do
			line_renderer.set_use_braille (False)
			line_renderer.render_single (a_values)
			line_renderer.set_use_braille (True)  -- Reset
			Result := line_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	scatter (a_x_values, a_y_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- Render X-Y scatter plot.
		require
			x_attached: a_x_values /= Void
			y_attached: a_y_values /= Void
			same_count: a_x_values.count = a_y_values.count
		do
			scatter_renderer.render_xy (a_x_values, a_y_values)
			Result := scatter_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	histogram (a_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- Render histogram (frequency distribution).
		require
			values_attached: a_values /= Void
		do
			histogram_renderer.render (a_values)
			Result := histogram_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

	histogram_with_bins (a_values: ARRAYED_LIST [REAL_64]; a_bin_count: INTEGER): STRING_32
			-- Render histogram with specified number of bins.
		require
			values_attached: a_values /= Void
			bins_positive: a_bin_count > 0
		do
			histogram_renderer.set_bin_count (a_bin_count)
			histogram_renderer.render (a_values)
			Result := histogram_renderer.as_string
		ensure
			result_attached: Result /= Void
		end

feature -- CSV-based rendering

	render_bar_chart (a_label_column, a_value_column: INTEGER): STRING
			-- Render bar chart using CSV columns for labels and values.
		require
			has_csv_data: csv_loader.has_data
			label_column_valid: a_label_column >= 1 and a_label_column <= csv_loader.column_count
			value_column_valid: a_value_column >= 1 and a_value_column <= csv_loader.column_count
		local
			l_labels: ARRAYED_LIST [STRING]
			l_values: ARRAYED_LIST [REAL_64]
		do
			l_labels := csv_loader.column_values (a_label_column)
			l_values := csv_loader.column_as_numbers (a_value_column)
			Result := bar_chart (l_labels, l_values)
		ensure
			result_not_empty: not Result.is_empty
		end

	render_line_chart (a_value_column: INTEGER): STRING_32
			-- Render line chart using CSV column for values.
		require
			has_csv_data: csv_loader.has_data
			column_valid: a_value_column >= 1 and a_value_column <= csv_loader.column_count
		local
			l_values: ARRAYED_LIST [REAL_64]
		do
			l_values := csv_loader.column_as_numbers (a_value_column)
			Result := line_chart (l_values)
		ensure
			result_attached: Result /= Void
		end

	render_sparkline (a_value_column: INTEGER): STRING_32
			-- Render sparkline using CSV column for values.
		require
			has_csv_data: csv_loader.has_data
			column_valid: a_value_column >= 1 and a_value_column <= csv_loader.column_count
		local
			l_values: ARRAYED_LIST [REAL_64]
		do
			l_values := csv_loader.column_as_numbers (a_value_column)
			Result := sparkline (l_values)
		ensure
			result_attached: Result /= Void
		end

	render_histogram (a_value_column: INTEGER): STRING_32
			-- Render histogram using CSV column for values.
		require
			has_csv_data: csv_loader.has_data
			column_valid: a_value_column >= 1 and a_value_column <= csv_loader.column_count
		local
			l_values: ARRAYED_LIST [REAL_64]
		do
			l_values := csv_loader.column_as_numbers (a_value_column)
			Result := histogram (l_values)
		ensure
			result_attached: Result /= Void
		end

	render_table: STRING
			-- Render CSV data as formatted ASCII table.
		require
			has_csv_data: csv_loader.has_data
		local
			l_headers: ARRAYED_LIST [STRING]
			l_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]
		do
			l_headers := csv_loader.headers
			l_rows := csv_loader.all_rows
			table_renderer.render (l_headers, l_rows)
			Result := table_renderer.as_string
		ensure
			result_not_empty: not Result.is_empty
		end

feature -- JSON-based rendering

	render_json_bar_chart: STRING
			-- Render bar chart from loaded JSON data.
		require
			has_json_data: json_loader.has_data
			has_labels: json_loader.has_labels
		do
			Result := bar_chart (json_loader.labels, json_loader.values)
		ensure
			result_attached: Result /= Void
		end

	render_json_line_chart: STRING_32
			-- Render line chart from loaded JSON data.
		require
			has_json_data: json_loader.has_data
		do
			Result := line_chart (json_loader.values)
		ensure
			result_attached: Result /= Void
		end

	render_json_scatter: STRING_32
			-- Render scatter plot from loaded JSON XY data.
		require
			has_json_xy: json_loader.has_xy_data
		do
			Result := scatter (json_loader.x_values, json_loader.y_values)
		ensure
			result_attached: Result /= Void
		end

	render_json_sparkline: STRING_32
			-- Render sparkline from loaded JSON data.
		require
			has_json_data: json_loader.has_data
		do
			Result := sparkline (json_loader.values)
		ensure
			result_attached: Result /= Void
		end

	render_json_histogram: STRING_32
			-- Render histogram from loaded JSON data.
		require
			has_json_data: json_loader.has_data
		do
			Result := histogram (json_loader.values)
		ensure
			result_attached: Result /= Void
		end

feature -- Configuration

	set_chart_size (a_width, a_height: INTEGER)
			-- Set size for all chart renderers.
		require
			width_positive: a_width > 0
			height_positive: a_height > 0
		do
			bar_renderer.set_bar_width (a_width)
			line_renderer.set_size (a_width, a_height)
			scatter_renderer.set_size (a_width, a_height)
			histogram_renderer.set_size (a_width, a_height)
		end

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set title for chart renderers that support it.
		do
			line_renderer.set_title (a_title)
			scatter_renderer.set_title (a_title)
			histogram_renderer.set_title (a_title)
		end

	set_braille_mode (a_use: BOOLEAN)
			-- Set braille mode for all chart renderers.
		do
			line_renderer.set_use_braille (a_use)
			scatter_renderer.set_use_braille (a_use)
			histogram_renderer.set_use_braille (a_use)
		end

invariant
	csv_loader_attached: csv_loader /= Void
	json_loader_attached: json_loader /= Void
	bar_renderer_attached: bar_renderer /= Void
	table_renderer_attached: table_renderer /= Void
	line_renderer_attached: line_renderer /= Void
	scatter_renderer_attached: scatter_renderer /= Void
	histogram_renderer_attached: histogram_renderer /= Void
	sparkline_renderer_attached: sparkline_renderer /= Void

end
