note
	description: "[
		Loads chart data from JSON format using simple_json.
		Supports simple arrays of numbers.

		Example JSON format:
		[10, 20, 30, 40, 50]
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	JSON_DATA_LOADER

create
	make

feature {NONE} -- Initialization

	make
			-- Create JSON data loader.
		do
			create labels.make (0)
			create values.make (0)
			create x_values.make (0)
			create y_values.make (0)
			create last_error.make_empty
			create json_helper.make
		ensure
			no_data: not has_data
		end

feature -- Access

	labels: ARRAYED_LIST [STRING]
			-- Labels loaded from JSON.

	values: ARRAYED_LIST [REAL_64]
			-- Values loaded from JSON.

	x_values: ARRAYED_LIST [REAL_64]
			-- X values for XY data.

	y_values: ARRAYED_LIST [REAL_64]
			-- Y values for XY data.

	last_error: STRING
			-- Last error message.

feature -- Status report

	has_data: BOOLEAN
			-- Is data loaded?
		do
			Result := not values.is_empty or not x_values.is_empty
		end

	has_labels: BOOLEAN
			-- Are labels available?
		do
			Result := not labels.is_empty
		end

	has_xy_data: BOOLEAN
			-- Is XY data available?
		do
			Result := not x_values.is_empty and not y_values.is_empty
		end

	row_count: INTEGER
			-- Number of data rows.
		do
			Result := values.count.max (x_values.count)
		end

feature -- Loading

	load_from_string (a_json: READABLE_STRING_GENERAL)
			-- Load data from JSON string.
			-- Supports: [1,2,3]
		require
			json_not_empty: not a_json.is_empty
		local
			l_json_str: STRING
		do
			clear
			l_json_str := a_json.to_string_8

			-- Parse as array
			if json_helper.is_array (l_json_str) then
				if attached json_helper.parse_array (l_json_str) as l_arr then
					load_numbers_from_array (l_arr)
				else
					last_error := "Failed to parse array"
				end
			else
				last_error := "JSON must be an array like [1,2,3]"
			end
		ensure
			data_or_error: has_data or not last_error.is_empty
		end

	load_from_file (a_path: READABLE_STRING_GENERAL)
			-- Load data from JSON file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: SIMPLE_FILE
		do
			clear
			create l_file.make (a_path)
			if l_file.exists then
				if attached l_file.read_all as l_content and then not l_content.is_empty then
					load_from_string (l_content)
				else
					last_error := "Empty file"
				end
			else
				last_error := "File not found: " + a_path.to_string_8
			end
		end

	clear
			-- Clear all loaded data.
		do
			labels.wipe_out
			values.wipe_out
			x_values.wipe_out
			y_values.wipe_out
			last_error.wipe_out
		ensure
			cleared: not has_data
		end

feature {NONE} -- Implementation

	json_helper: SIMPLE_JSON_QUICK
			-- JSON parsing helper.

	load_numbers_from_array (a_array: SIMPLE_JSON_ARRAY)
			-- Load numbers from JSON array.
		local
			l_i: INTEGER
		do
			from l_i := 1 until l_i > a_array.count loop
				if attached a_array.item (l_i) as l_item and then l_item.is_number then
					values.extend (l_item.as_real)
				end
				l_i := l_i + 1
			end
		end

invariant
	labels_attached: labels /= Void
	values_attached: values /= Void
	x_values_attached: x_values /= Void
	y_values_attached: y_values /= Void
	xy_sync: x_values.count = y_values.count

end
