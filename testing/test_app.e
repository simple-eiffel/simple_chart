note
	description: "Test runner application for simple_chart"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_CHART tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests
			run_simple_chart_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
			-- Run LIB_TESTS test cases.
		do
			create lib_tests
			run_test (agent lib_tests.test_creation, "test_creation")
		end

	run_simple_chart_tests
			-- Run TEST_SIMPLE_CHART test cases.
		do
			create chart_tests
			run_test (agent chart_tests.test_make_creates_all_components, "test_make_creates_all_components")
			run_test (agent chart_tests.test_load_csv_string_valid_data, "test_load_csv_string_valid_data")
			run_test (agent chart_tests.test_load_csv_string_single_row, "test_load_csv_string_single_row")
			run_test (agent chart_tests.test_load_csv_string_many_columns, "test_load_csv_string_many_columns")
			run_test (agent chart_tests.test_load_csv_string_whitespace_values, "test_load_csv_string_whitespace_values")
			run_test (agent chart_tests.test_load_csv_string_empty_cells, "test_load_csv_string_empty_cells")
			run_test (agent chart_tests.test_render_bar_chart_valid, "test_render_bar_chart_valid")
			run_test (agent chart_tests.test_render_bar_chart_single_row, "test_render_bar_chart_single_row")
			run_test (agent chart_tests.test_render_bar_chart_zero_values, "test_render_bar_chart_zero_values")
			run_test (agent chart_tests.test_render_bar_chart_negative_values, "test_render_bar_chart_negative_values")
			run_test (agent chart_tests.test_render_table_valid, "test_render_table_valid")
			run_test (agent chart_tests.test_render_table_wide_columns, "test_render_table_wide_columns")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

	chart_tests: TEST_SIMPLE_CHART

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end