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
			run_visual_tests
			run_output_tests

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

	run_visual_tests
			-- Run visual chart tests that generate output files.
		do
			print ("%N--- Visual Chart Tests (outputs to testing/output/) ---%N")
			create visual_tests.make

			-- Bar chart tests
			run_test (agent visual_tests.test_bar_chart_monthly_sales, "visual_bar_monthly_sales")
			run_test (agent visual_tests.test_bar_chart_product_categories, "visual_bar_product_categories")

			-- Sparkline tests
			run_test (agent visual_tests.test_sparkline_cpu_usage, "visual_sparkline_cpu")
			run_test (agent visual_tests.test_sparkline_memory, "visual_sparkline_memory")
			run_test (agent visual_tests.test_sparkline_network, "visual_sparkline_network")
			run_test (agent visual_tests.test_sparkline_disk_io, "visual_sparkline_disk")
			run_test (agent visual_tests.test_sparkline_dashboard, "visual_sparkline_dashboard")

			-- Line chart tests
			run_test (agent visual_tests.test_line_chart_stock_30_days, "visual_line_stock_30d")
			run_test (agent visual_tests.test_line_chart_stock_90_days, "visual_line_stock_90d")
			run_test (agent visual_tests.test_line_chart_stock_ascii, "visual_line_stock_ascii")
			run_test (agent visual_tests.test_line_chart_temperature, "visual_line_temperature")
			run_test (agent visual_tests.test_line_chart_hourly_temp, "visual_line_hourly_temp")
			run_test (agent visual_tests.test_line_chart_multi_series, "visual_line_multi_series")

			-- Scatter plot tests
			run_test (agent visual_tests.test_scatter_height_weight, "visual_scatter_height_weight")
			run_test (agent visual_tests.test_scatter_study_scores, "visual_scatter_study_scores")
			run_test (agent visual_tests.test_scatter_ascii_mode, "visual_scatter_ascii")

			-- Histogram tests
			run_test (agent visual_tests.test_histogram_exam_scores, "visual_histogram_exam")
			run_test (agent visual_tests.test_histogram_response_times, "visual_histogram_response")
			run_test (agent visual_tests.test_histogram_age_distribution, "visual_histogram_age")
			run_test (agent visual_tests.test_histogram_custom_bins, "visual_histogram_5bins")
			run_test (agent visual_tests.test_histogram_many_bins, "visual_histogram_20bins")

			-- Comprehensive report
			run_test (agent visual_tests.test_comprehensive_report, "visual_comprehensive_report")

			print ("%NVisual outputs written to: testing/output/%N")
		end

	run_output_tests
			-- Run SVG, PNG, and PDF output tests.
		do
			print ("%N--- SVG Image Tests ---%N")
			create output_tests.make

			-- SVG image tests
			run_test (agent output_tests.test_svg_bar_chart, "svg_bar_chart")
			run_test (agent output_tests.test_svg_line_chart, "svg_line_chart")
			run_test (agent output_tests.test_svg_scatter_plot, "svg_scatter_plot")
			run_test (agent output_tests.test_svg_histogram, "svg_histogram")
			run_test (agent output_tests.test_svg_multi_chart_page, "svg_multi_chart_html")

			print ("%N--- PNG Image Tests (Cairo) ---%N")

			-- PNG image tests using Cairo
			run_test (agent output_tests.test_png_bar_chart, "png_bar_chart")
			run_test (agent output_tests.test_png_line_chart, "png_line_chart")
			run_test (agent output_tests.test_png_scatter_plot, "png_scatter_plot")
			run_test (agent output_tests.test_png_histogram, "png_histogram")

			print ("%N--- PDF Tests ---%N")

			-- PDF tests (only if PDF engine available)
			run_test (agent output_tests.test_pdf_chart_report, "pdf_chart_report")
			run_test (agent output_tests.test_pdf_dashboard, "pdf_dashboard")

			print ("%NSVG/PNG/PDF outputs written to: testing/output/%N")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

	chart_tests: TEST_SIMPLE_CHART

	visual_tests: TEST_CHART_VISUAL

	output_tests: TEST_CHART_OUTPUT

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