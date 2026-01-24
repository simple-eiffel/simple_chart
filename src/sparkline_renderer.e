note
	description: "[
		Renders compact inline sparkline charts using Unicode block characters.
		Uses characters U+2581-U+2588 for 8 height levels.
		Single-line output ideal for embedding in tables or dashboards.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	SPARKLINE_RENDERER

create
	make

feature {NONE} -- Initialization

	make
			-- Create sparkline renderer.
		do
			create output.make_empty
			show_min_max := False
			min_marker := block_char (0)
			max_marker := block_char (7)
		ensure
			output_empty: output.is_empty
		end

feature -- Access

	output: STRING_32
			-- Rendered output.

	as_string: STRING_32
			-- Get rendered sparkline as string.
		do
			Result := output.twin
		ensure
			result_attached: Result /= Void
		end

	as_string_8: STRING
			-- Get rendered sparkline as UTF-8 string.
		do
			Result := output.to_string_8
		ensure
			result_attached: Result /= Void
		end

feature -- Settings

	show_min_max: BOOLEAN
			-- Show min/max values at end?

	min_marker: CHARACTER_32
			-- Character to mark minimum value.

	max_marker: CHARACTER_32
			-- Character to mark maximum value.

	set_show_min_max (a_show: BOOLEAN)
			-- Set whether to show min/max values.
		do
			show_min_max := a_show
		ensure
			set: show_min_max = a_show
		end

feature -- Status report

	is_rendered: BOOLEAN
			-- Has a sparkline been rendered?
		do
			Result := not output.is_empty
		end

feature -- Rendering

	render (a_values: ARRAYED_LIST [REAL_64])
			-- Render sparkline from values.
		require
			values_attached: a_values /= Void
		local
			l_min, l_max, l_range, l_value: REAL_64
			l_level: INTEGER
			l_char: CHARACTER_32
		do
			output.wipe_out

			if a_values.is_empty then
				-- Nothing to render
			else
				-- Find min and max
				l_min := a_values.first
				l_max := a_values.first
				across a_values as v loop
					if v < l_min then l_min := v end
					if v > l_max then l_max := v end
				end

				l_range := l_max - l_min
				if l_range = 0.0 then
					l_range := 1.0  -- Avoid division by zero
				end

				-- Render each value as a block character
				across a_values as v loop
					l_value := v
					-- Normalize to 0-7 range (8 levels)
					l_level := (((l_value - l_min) / l_range) * 7.0).rounded.max (0).min (7)
					l_char := block_char (l_level)
					output.append_character (l_char)
				end

				-- Optionally append min/max
				if show_min_max then
					output.append (" ")
					output.append (format_number (l_min))
					output.append ("-")
					output.append (format_number (l_max))
				end
			end
		ensure
			rendered_if_data: not a_values.is_empty implies is_rendered
		end

	render_with_baseline (a_values: ARRAYED_LIST [REAL_64]; a_baseline: REAL_64)
			-- Render sparkline with custom baseline (values below baseline use lower blocks).
		require
			values_attached: a_values /= Void
		local
			l_min, l_max, l_range, l_value: REAL_64
			l_level: INTEGER
		do
			output.wipe_out

			if a_values.is_empty then
				-- Nothing to render
			else
				-- Find actual range
				l_min := a_baseline
				l_max := a_baseline
				across a_values as v loop
					if v < l_min then l_min := v end
					if v > l_max then l_max := v end
				end

				l_range := l_max - l_min
				if l_range = 0.0 then
					l_range := 1.0
				end

				-- Render
				across a_values as v loop
					l_value := v
					l_level := (((l_value - l_min) / l_range) * 7.0).rounded.max (0).min (7)
					output.append_character (block_char (l_level))
				end
			end
		end

feature -- Convenience

	sparkline (a_values: ARRAYED_LIST [REAL_64]): STRING_32
			-- One-liner: render and return sparkline string.
		require
			values_attached: a_values /= Void
		do
			render (a_values)
			Result := as_string
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	Block_base: INTEGER = 0x2581
			-- Unicode block base character (lower one-eighth block).

	block_char (a_level: INTEGER): CHARACTER_32
			-- Block character for level 0-7 (U+2581 to U+2588).
		require
			level_valid: a_level >= 0 and a_level <= 7
		do
			Result := (Block_base + a_level).to_character_32
		end

	format_number (a_value: REAL_64): STRING_32
			-- Format number for display (compact).
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

invariant
	output_attached: output /= Void

end
