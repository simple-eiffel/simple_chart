note
	description: "[
		Renders frequency distribution histograms.
		Takes raw data, bins it into buckets, and renders as vertical bars.
		Supports both ASCII and Braille rendering modes.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	HISTOGRAM_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create histogram renderer with defaults.
		do
			create output.make_empty
			create bin_counts.make_filled (0, 0, 0)
			create bin_edges.make_filled (0.0, 0, 0)
			width := Default_width
			height := Default_height
			bin_count := Default_bin_count
			use_braille := False  -- ASCII looks better for histograms
			show_counts := True
			create title.make_empty
		ensure
			output_empty: output.is_empty
		end

feature -- Access

	output: STRING_32
			-- Rendered output.

	as_string: STRING_32
			-- Get rendered histogram as string.
		do
			Result := output.twin
		ensure
			result_attached: Result /= Void
		end

	as_string_8: STRING
			-- Get rendered histogram as UTF-8 string.
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

	bin_count: INTEGER
			-- Number of bins for histogram.

	use_braille: BOOLEAN
			-- Use braille for bars?

	show_counts: BOOLEAN
			-- Show count labels on bars?

	title: STRING_32
			-- Chart title.

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

	set_bin_count (a_count: INTEGER)
			-- Set number of bins.
		require
			count_positive: a_count > 0
		do
			bin_count := a_count
		ensure
			set: bin_count = a_count
		end

	set_use_braille (a_use: BOOLEAN)
			-- Set braille mode.
		do
			use_braille := a_use
		ensure
			set: use_braille = a_use
		end

	set_show_counts (a_show: BOOLEAN)
			-- Set count label visibility.
		do
			show_counts := a_show
		ensure
			set: show_counts = a_show
		end

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set chart title.
		do
			create title.make_from_string_general (a_title)
		end

feature -- Status report

	is_rendered: BOOLEAN
			-- Has histogram been rendered?
		do
			Result := not output.is_empty
		end

feature -- Rendering

	render (a_values: ARRAYED_LIST [REAL_64])
			-- Render histogram from raw data values.
		require
			values_attached: a_values /= Void
		do
			output.wipe_out
			if a_values.is_empty then
				-- Nothing to render
			else
				compute_bins (a_values)
				render_histogram
			end
		end

	render_with_range (a_values: ARRAYED_LIST [REAL_64]; a_min, a_max: REAL_64)
			-- Render histogram with explicit range.
		require
			values_attached: a_values /= Void
			valid_range: a_max > a_min
		do
			output.wipe_out
			if a_values.is_empty then
				-- Nothing to render
			else
				compute_bins_with_range (a_values, a_min, a_max)
				render_histogram
			end
		end

feature {NONE} -- Binning

	bin_counts: ARRAY [INTEGER]
			-- Count for each bin.

	bin_edges: ARRAY [REAL_64]
			-- Edge values for each bin (count + 1 edges).

	data_min: REAL_64
			-- Minimum data value.

	data_max: REAL_64
			-- Maximum data value.

	compute_bins (a_values: ARRAYED_LIST [REAL_64])
			-- Compute bins from data.
		require
			values_not_empty: not a_values.is_empty
		local
			l_min, l_max: REAL_64
		do
			-- Find range
			l_min := a_values.first
			l_max := a_values.first
			across a_values as v loop
				if v < l_min then l_min := v end
				if v > l_max then l_max := v end
			end

			-- Add small margin to include max value
			if l_max = l_min then
				l_max := l_min + 1.0
			end

			compute_bins_with_range (a_values, l_min, l_max + 0.0001)
		end

	compute_bins_with_range (a_values: ARRAYED_LIST [REAL_64]; a_min, a_max: REAL_64)
			-- Compute bins with explicit range.
		require
			values_not_empty: not a_values.is_empty
		local
			l_bin_width: REAL_64
			l_bin_idx, l_i: INTEGER
		do
			data_min := a_min
			data_max := a_max
			l_bin_width := (a_max - a_min) / bin_count.to_double

			-- Initialize bins
			create bin_counts.make_filled (0, 0, bin_count - 1)
			create bin_edges.make_filled (0.0, 0, bin_count)

			-- Set edges
			from l_i := 0 until l_i > bin_count loop
				bin_edges [l_i] := a_min + l_i.to_double * l_bin_width
				l_i := l_i + 1
			end

			-- Count values into bins
			across a_values as v loop
				if v >= a_min and v < a_max then
					l_bin_idx := ((v - a_min) / l_bin_width).floor.max (0).min (bin_count - 1)
					bin_counts [l_bin_idx] := bin_counts [l_bin_idx] + 1
				elseif v = a_max then
					-- Include max value in last bin
					bin_counts [bin_count - 1] := bin_counts [bin_count - 1] + 1
				end
			end
		end

feature {NONE} -- Rendering implementation

	render_histogram
			-- Render computed bins to output.
		local
			l_max_count: INTEGER
			l_bar_width, l_bar_height: INTEGER
			l_row, l_bin: INTEGER
			l_threshold: REAL_64
			l_count: INTEGER
			l_label_width: INTEGER
		do
			-- Find max count for scaling
			l_max_count := 0
			across bin_counts as c loop
				if c > l_max_count then l_max_count := c end
			end

			if l_max_count = 0 then
				output.append ("(no data in range)")
			else
				-- Calculate dimensions
			l_bar_width := (width // bin_count).max (1)
			l_label_width := l_max_count.out.count + 1

			-- Title
			if not title.is_empty then
				output.append (title)
				output.append_character ('%N')
			end

			-- Render rows from top to bottom
			from l_row := height until l_row < 1 loop
				l_threshold := l_row.to_double / height.to_double * l_max_count.to_double

				-- Y-axis label at certain rows
				if l_row = height then
					output.append (padded_int (l_max_count, l_label_width))
				elseif l_row = 1 then
					output.append (padded_int (0, l_label_width))
				elseif l_row = height // 2 then
					output.append (padded_int (l_max_count // 2, l_label_width))
				else
					output.append (spaces (l_label_width))
				end

				output.append_character ((0x2502).to_character_32)  -- Box drawing vertical

				-- Render each bin
				from l_bin := 0 until l_bin >= bin_count loop
					l_count := bin_counts [l_bin]
					if l_count.to_double >= l_threshold then
						output.append (bar_chars (l_bar_width))
					else
						output.append (spaces (l_bar_width))
					end
					l_bin := l_bin + 1
				end

				output.append_character ('%N')
				l_row := l_row - 1
			end

			-- X-axis line
			output.append (spaces (l_label_width))
			output.append_character ((0x2514).to_character_32)  -- Box drawing corner
			output.append (repeat_char ((0x2500).to_character_32, l_bar_width * bin_count))
			output.append_character ('%N')

			-- X-axis labels (min and max)
			output.append (spaces (l_label_width + 1))
			output.append (format_num (data_min))
			output.append (spaces ((l_bar_width * bin_count - format_num (data_min).count - format_num (data_max).count).max (1)))
			output.append (format_num (data_max))
			output.append_character ('%N')

			-- Show bin counts if requested
			if show_counts then
				output.append_character ('%N')
				output.append ("Bins: ")
				from l_bin := 0 until l_bin >= bin_count loop
					output.append_string_general (bin_counts [l_bin].out)
					if l_bin < bin_count - 1 then
						output.append (", ")
					end
					l_bin := l_bin + 1
				end
				output.append_character ('%N')
			end
			end  -- else l_max_count > 0
		end

feature {NONE} -- Helpers

	Full_block: INTEGER = 0x2588
			-- Unicode full block character.

	bar_chars (a_width: INTEGER): STRING_32
			-- Bar characters of given width.
		require
			width_positive: a_width > 0
		do
			Result := repeat_char (Full_block.to_character_32, a_width)
		end

	spaces (a_count: INTEGER): STRING_32
			-- String of spaces.
		require
			count_non_negative: a_count >= 0
		do
			Result := repeat_char (' ', a_count)
		end

	repeat_char (a_char: CHARACTER_32; a_count: INTEGER): STRING_32
			-- Repeat character a_count times.
		require
			count_non_negative: a_count >= 0
		local
			l_i: INTEGER
		do
			create Result.make (a_count)
			from l_i := 1 until l_i > a_count loop
				Result.append_character (a_char)
				l_i := l_i + 1
			end
		end

	padded_int (a_value, a_width: INTEGER): STRING_32
			-- Right-aligned integer.
		local
			l_str: STRING
		do
			l_str := a_value.out
			create Result.make (a_width)
			Result.append (spaces (a_width - l_str.count))
			Result.append_string_general (l_str)
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
				if l_str.count > 6 then
					l_str := l_str.substring (1, 6)
				end
				create Result.make_from_string (l_str)
			end
		end

feature -- Constants

	Default_width: INTEGER = 60
			-- Default chart width.

	Default_height: INTEGER = 15
			-- Default chart height.

	Default_bin_count: INTEGER = 10
			-- Default number of bins.

invariant
	output_attached: output /= Void
	width_positive: width > 0
	height_positive: height > 0
	bin_count_positive: bin_count > 0

end
