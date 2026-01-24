note
	description: "[
		Visual chart tests that output to files.
		Generates all chart types with realistic data.
		Outputs saved to testing/output/ for visual verification.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	TEST_CHART_VISUAL

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize test suite.
		do
			create chart.make
			create data.make
			output_dir := "testing/output/"
		end

feature -- Access

	chart: SIMPLE_CHART
			-- Chart facade under test.

	data: TEST_DATA_GENERATOR
			-- Test data generator.

	output_dir: STRING
			-- Output directory path.

feature -- Bar Chart Tests

	test_bar_chart_monthly_sales
			-- Bar chart: Monthly sales data.
		local
			l_result: STRING
		do
			l_result := chart.bar_chart (data.monthly_sales_labels, data.monthly_sales_values)
			write_output ("bar_monthly_sales.txt", l_result)
			check not l_result.is_empty end
		end

	test_bar_chart_product_categories
			-- Bar chart: Sales by product category.
		local
			l_result: STRING
		do
			l_result := chart.bar_chart (data.product_category_labels, data.product_category_values)
			write_output ("bar_product_categories.txt", l_result)
			check not l_result.is_empty end
		end

feature -- Sparkline Tests

	test_sparkline_cpu_usage
			-- Sparkline: CPU usage pattern.
		local
			l_result: STRING_32
		do
			l_result := chart.sparkline (data.cpu_usage_1min)
			write_output_32 ("sparkline_cpu.txt", l_result)
			check not l_result.is_empty end
		end

	test_sparkline_memory
			-- Sparkline: Memory usage with GC drops.
		local
			l_result: STRING_32
		do
			l_result := chart.sparkline (data.memory_usage)
			write_output_32 ("sparkline_memory.txt", l_result)
			check not l_result.is_empty end
		end

	test_sparkline_network
			-- Sparkline: Network throughput.
		local
			l_result: STRING_32
		do
			l_result := chart.sparkline (data.network_throughput)
			write_output_32 ("sparkline_network.txt", l_result)
			check not l_result.is_empty end
		end

	test_sparkline_disk_io
			-- Sparkline: Disk I/O.
		local
			l_result: STRING_32
		do
			l_result := chart.sparkline (data.disk_io)
			write_output_32 ("sparkline_disk.txt", l_result)
			check not l_result.is_empty end
		end

	test_sparkline_dashboard
			-- Multiple sparklines in dashboard format.
		local
			l_output: STRING_32
		do
			create l_output.make (500)
			l_output.append ("=== System Dashboard ===%N%N")
			l_output.append ("CPU:     ")
			l_output.append (chart.sparkline (data.cpu_usage_1min))
			l_output.append ("%NMemory:  ")
			l_output.append (chart.sparkline (data.memory_usage))
			l_output.append ("%NNetwork: ")
			l_output.append (chart.sparkline (data.network_throughput))
			l_output.append ("%NDisk IO: ")
			l_output.append (chart.sparkline (data.disk_io))
			l_output.append ("%N")
			write_output_32 ("sparkline_dashboard.txt", l_output)
			check not l_output.is_empty end
		end

feature -- Line Chart Tests

	test_line_chart_stock_30_days
			-- Line chart: 30-day stock price (braille).
		local
			l_result: STRING_32
		do
			chart.set_title ("Stock Price - 30 Days")
			l_result := chart.line_chart (data.stock_prices_30_days)
			write_output_32 ("line_stock_30d_braille.txt", l_result)
			check not l_result.is_empty end
		end

	test_line_chart_stock_90_days
			-- Line chart: 90-day stock price (braille).
		local
			l_result: STRING_32
		do
			chart.set_title ("Stock Price - 90 Days (Upward Trend)")
			l_result := chart.line_chart (data.stock_prices_90_days)
			write_output_32 ("line_stock_90d_braille.txt", l_result)
			check not l_result.is_empty end
		end

	test_line_chart_stock_ascii
			-- Line chart: Stock price in ASCII mode.
		local
			l_result: STRING_32
		do
			chart.set_title ("Stock Price - ASCII Mode")
			l_result := chart.line_chart_ascii (data.stock_prices_30_days)
			write_output_32 ("line_stock_ascii.txt", l_result)
			check not l_result.is_empty end
		end

	test_line_chart_temperature
			-- Line chart: Daily temperatures.
		local
			l_result: STRING_32
		do
			chart.set_title ("Daily High Temperatures (F)")
			l_result := chart.line_chart (data.daily_temperatures)
			write_output_32 ("line_temperature.txt", l_result)
			check not l_result.is_empty end
		end

	test_line_chart_hourly_temp
			-- Line chart: Hourly temperatures.
		local
			l_result: STRING_32
		do
			chart.set_title ("24-Hour Temperature Pattern")
			l_result := chart.line_chart (data.hourly_temperatures)
			write_output_32 ("line_hourly_temp.txt", l_result)
			check not l_result.is_empty end
		end

	test_line_chart_multi_series
			-- Line chart: Multiple stock comparison.
		local
			l_series: ARRAYED_LIST [ARRAYED_LIST [REAL_64]]
			l_i: INTEGER
			l_names: ARRAY [STRING]
		do
			chart.line_renderer.clear_series
			l_series := data.multi_stock_series
			l_names := <<"Tech Stock", "Blue Chip", "Growth Stock">>
			from l_i := 1 until l_i > l_series.count loop
				chart.line_renderer.add_series (l_names [l_i], l_series.i_th (l_i))
				l_i := l_i + 1
			end
			chart.line_renderer.set_title ("Multi-Stock Comparison")
			chart.line_renderer.render
			write_output_32 ("line_multi_stock.txt", chart.line_renderer.as_string)
			check chart.line_renderer.is_rendered end
		end

feature -- Scatter Plot Tests

	test_scatter_height_weight
			-- Scatter: Height vs Weight correlation.
		local
			l_result: STRING_32
		do
			chart.scatter_renderer.set_title ("Height vs Weight")
			chart.scatter_renderer.set_x_label ("Height (in)")
			chart.scatter_renderer.set_y_label ("Weight (lb)")
			l_result := chart.scatter (data.height_weight_x, data.height_weight_y)
			write_output_32 ("scatter_height_weight.txt", l_result)
			check not l_result.is_empty end
		end

	test_scatter_study_scores
			-- Scatter: Study hours vs exam scores.
		local
			l_result: STRING_32
		do
			chart.scatter_renderer.set_title ("Study Hours vs Exam Scores")
			chart.scatter_renderer.set_x_label ("Hours")
			chart.scatter_renderer.set_y_label ("Score")
			l_result := chart.scatter (data.study_hours_x, data.exam_scores_y)
			write_output_32 ("scatter_study_scores.txt", l_result)
			check not l_result.is_empty end
		end

	test_scatter_ascii_mode
			-- Scatter: ASCII mode.
		local
			l_result: STRING_32
		do
			chart.scatter_renderer.set_use_braille (False)
			chart.scatter_renderer.set_title ("Height vs Weight (ASCII)")
			l_result := chart.scatter (data.height_weight_x, data.height_weight_y)
			chart.scatter_renderer.set_use_braille (True)  -- Reset
			write_output_32 ("scatter_height_weight_ascii.txt", l_result)
			check not l_result.is_empty end
		end

feature -- Histogram Tests

	test_histogram_exam_scores
			-- Histogram: Exam score distribution.
		local
			l_result: STRING_32
		do
			chart.histogram_renderer.set_title ("Exam Score Distribution")
			l_result := chart.histogram (data.exam_scores_distribution)
			write_output_32 ("histogram_exam_scores.txt", l_result)
			check not l_result.is_empty end
		end

	test_histogram_response_times
			-- Histogram: API response times (skewed).
		local
			l_result: STRING_32
		do
			chart.histogram_renderer.set_title ("API Response Times (ms)")
			l_result := chart.histogram (data.response_times_ms)
			write_output_32 ("histogram_response_times.txt", l_result)
			check not l_result.is_empty end
		end

	test_histogram_age_distribution
			-- Histogram: Customer age demographics.
		local
			l_result: STRING_32
		do
			chart.histogram_renderer.set_title ("Customer Age Distribution")
			l_result := chart.histogram (data.age_distribution)
			write_output_32 ("histogram_age.txt", l_result)
			check not l_result.is_empty end
		end

	test_histogram_custom_bins
			-- Histogram: Custom bin count.
		local
			l_result: STRING_32
		do
			chart.histogram_renderer.set_title ("Exam Scores (5 bins)")
			l_result := chart.histogram_with_bins (data.exam_scores_distribution, 5)
			write_output_32 ("histogram_5_bins.txt", l_result)
			check not l_result.is_empty end
		end

	test_histogram_many_bins
			-- Histogram: Many bins for detail.
		local
			l_result: STRING_32
		do
			chart.histogram_renderer.set_title ("Response Times (20 bins)")
			chart.histogram_renderer.set_bin_count (20)
			l_result := chart.histogram (data.response_times_ms)
			chart.histogram_renderer.set_bin_count (10)  -- Reset
			write_output_32 ("histogram_20_bins.txt", l_result)
			check not l_result.is_empty end
		end

feature -- Comprehensive Report Test

	test_comprehensive_report
			-- Generate a comprehensive chart report.
		local
			l_report: STRING_32
		do
			create l_report.make (10000)

			l_report.append ("========================================%N")
			l_report.append ("   SIMPLE_CHART VISUAL TEST REPORT%N")
			l_report.append ("========================================%N%N")

			-- Sparklines section
			l_report.append ("--- SPARKLINES (System Metrics) ---%N%N")
			l_report.append ("CPU Usage:     ")
			l_report.append (chart.sparkline (data.cpu_usage_1min))
			l_report.append ("%NMemory:        ")
			l_report.append (chart.sparkline (data.memory_usage))
			l_report.append ("%NNetwork (Mbps):")
			l_report.append (chart.sparkline (data.network_throughput))
			l_report.append ("%NDisk I/O:      ")
			l_report.append (chart.sparkline (data.disk_io))
			l_report.append ("%N%N")

			-- Bar chart section
			l_report.append ("--- BAR CHART (Monthly Sales) ---%N%N")
			l_report.append_string_general (chart.bar_chart (data.monthly_sales_labels, data.monthly_sales_values))
			l_report.append ("%N")

			-- Line chart section
			l_report.append ("--- LINE CHART (Stock Price 30 Days) ---%N%N")
			chart.set_title ("")
			l_report.append (chart.line_chart (data.stock_prices_30_days))
			l_report.append ("%N")

			-- Scatter plot section
			l_report.append ("--- SCATTER PLOT (Height vs Weight) ---%N%N")
			chart.scatter_renderer.set_title ("")
			l_report.append (chart.scatter (data.height_weight_x, data.height_weight_y))
			l_report.append ("%N")

			-- Histogram section
			l_report.append ("--- HISTOGRAM (Exam Scores) ---%N%N")
			chart.histogram_renderer.set_title ("")
			l_report.append (chart.histogram (data.exam_scores_distribution))
			l_report.append ("%N")

			l_report.append ("========================================%N")
			l_report.append ("          END OF REPORT%N")
			l_report.append ("========================================%N")

			write_output_32 ("comprehensive_report.txt", l_report)
			check not l_report.is_empty end
		end

feature {NONE} -- File Output

	write_output (a_filename: STRING; a_content: STRING)
			-- Write STRING content to output file.
		local
			l_file: SIMPLE_FILE
			l_ok: BOOLEAN
		do
			create l_file.make (output_dir + a_filename)
			l_ok := l_file.write_all (a_content)
		end

	write_output_32 (a_filename: STRING; a_content: STRING_32)
			-- Write STRING_32 content to output file.
		local
			l_file: SIMPLE_FILE
			l_ok: BOOLEAN
		do
			create l_file.make (output_dir + a_filename)
			l_ok := l_file.write_all (a_content.to_string_8)
		end

end
