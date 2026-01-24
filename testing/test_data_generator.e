note
	description: "[
		Generates realistic test data for chart testing.
		Simulates real-world scenarios: sales, stocks, weather, etc.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	TEST_DATA_GENERATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize random seed.
		do
			create random.make
			random.start
		end

feature -- Access

	random: RANDOM
			-- Random number generator.

feature -- Sales Data (Bar Charts)

	monthly_sales_labels: ARRAYED_LIST [STRING]
			-- Month labels for sales data.
		do
			create Result.make_from_array (<<
				"Jan", "Feb", "Mar", "Apr", "May", "Jun",
				"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
			>>)
		end

	monthly_sales_values: ARRAYED_LIST [REAL_64]
			-- Simulated monthly sales (seasonal pattern).
		do
			create Result.make (12)
			Result.extend (45000.0)   -- Jan (post-holiday low)
			Result.extend (38000.0)   -- Feb
			Result.extend (52000.0)   -- Mar (spring pickup)
			Result.extend (61000.0)   -- Apr
			Result.extend (58000.0)   -- May
			Result.extend (72000.0)   -- Jun (summer peak)
			Result.extend (68000.0)   -- Jul
			Result.extend (65000.0)   -- Aug
			Result.extend (55000.0)   -- Sep (back to school)
			Result.extend (48000.0)   -- Oct
			Result.extend (82000.0)   -- Nov (Black Friday)
			Result.extend (95000.0)   -- Dec (holiday peak)
		end

	product_category_labels: ARRAYED_LIST [STRING]
			-- Product category names.
		do
			create Result.make_from_array (<<
				"Electronics", "Clothing", "Home & Garden",
				"Sports", "Books", "Toys", "Food & Beverage"
			>>)
		end

	product_category_values: ARRAYED_LIST [REAL_64]
			-- Sales by product category.
		do
			create Result.make (7)
			Result.extend (125000.0)  -- Electronics
			Result.extend (89000.0)   -- Clothing
			Result.extend (67000.0)   -- Home & Garden
			Result.extend (45000.0)   -- Sports
			Result.extend (32000.0)   -- Books
			Result.extend (28000.0)   -- Toys
			Result.extend (54000.0)   -- Food & Beverage
		end

feature -- Stock Data (Line Charts)

	stock_prices_30_days: ARRAYED_LIST [REAL_64]
			-- Simulated stock price over 30 days (random walk).
		local
			l_price: REAL_64
			l_i: INTEGER
			l_change: REAL_64
		do
			create Result.make (30)
			l_price := 150.0  -- Starting price
			from l_i := 1 until l_i > 30 loop
				Result.extend (l_price)
				-- Random walk: -2% to +2%
				random.forth
				l_change := (random.double_item - 0.5) * 4.0
				l_price := l_price * (1.0 + l_change / 100.0)
				l_price := l_price.max (100.0).min (200.0)
				l_i := l_i + 1
			end
		end

	stock_prices_90_days: ARRAYED_LIST [REAL_64]
			-- Simulated stock price over 90 days (upward trend with volatility).
		local
			l_price: REAL_64
			l_i: INTEGER
			l_change: REAL_64
		do
			create Result.make (90)
			l_price := 100.0
			from l_i := 1 until l_i > 90 loop
				Result.extend (l_price)
				random.forth
				-- Slight upward bias: -1.5% to +2%
				l_change := (random.double_item - 0.43) * 3.5
				l_price := l_price * (1.0 + l_change / 100.0)
				l_price := l_price.max (80.0).min (180.0)
				l_i := l_i + 1
			end
		end

	multi_stock_series: ARRAYED_LIST [ARRAYED_LIST [REAL_64]]
			-- Three stock series for comparison.
		local
			l_series: ARRAYED_LIST [REAL_64]
			l_price: REAL_64
			l_i, l_s: INTEGER
			l_base: ARRAY [REAL_64]
			l_volatility: ARRAY [REAL_64]
		do
			create Result.make (3)
			l_base := <<100.0, 150.0, 75.0>>
			l_volatility := <<2.0, 3.0, 4.0>>

			from l_s := 1 until l_s > 3 loop
				create l_series.make (30)
				l_price := l_base [l_s]
				from l_i := 1 until l_i > 30 loop
					l_series.extend (l_price)
					random.forth
					l_price := l_price * (1.0 + (random.double_item - 0.5) * l_volatility [l_s] / 100.0)
					l_i := l_i + 1
				end
				Result.extend (l_series)
				l_s := l_s + 1
			end
		end

feature -- Temperature Data (Line Charts, Scatter)

	daily_temperatures: ARRAYED_LIST [REAL_64]
			-- Daily high temperatures for a month (Fahrenheit).
		do
			create Result.make_from_array (<<
				72.0, 75.0, 71.0, 68.0, 65.0, 70.0, 73.0,
				78.0, 82.0, 85.0, 83.0, 79.0, 76.0, 74.0,
				72.0, 70.0, 68.0, 71.0, 75.0, 79.0, 82.0,
				80.0, 77.0, 74.0, 72.0, 69.0, 67.0, 70.0,
				73.0, 76.0
			>>)
		end

	hourly_temperatures: ARRAYED_LIST [REAL_64]
			-- Hourly temperatures for one day.
		do
			create Result.make_from_array (<<
				58.0, 56.0, 55.0, 54.0, 53.0, 54.0,  -- Midnight to 5am
				56.0, 60.0, 65.0, 70.0, 74.0, 78.0,  -- 6am to 11am
				81.0, 83.0, 84.0, 83.0, 80.0, 76.0,  -- Noon to 5pm
				72.0, 68.0, 65.0, 63.0, 61.0, 59.0   -- 6pm to 11pm
			>>)
		end

feature -- Scatter Plot Data

	height_weight_x: ARRAYED_LIST [REAL_64]
			-- Heights in inches (scatter plot X).
		do
			create Result.make_from_array (<<
				62.0, 64.0, 65.0, 66.0, 67.0, 68.0, 69.0, 70.0,
				71.0, 72.0, 73.0, 74.0, 75.0, 63.0, 65.0, 67.0,
				69.0, 71.0, 73.0, 75.0, 64.0, 66.0, 68.0, 70.0,
				72.0, 74.0, 76.0, 65.0, 67.0, 69.0
			>>)
		end

	height_weight_y: ARRAYED_LIST [REAL_64]
			-- Weights in pounds (scatter plot Y).
		do
			create Result.make_from_array (<<
				115.0, 125.0, 130.0, 140.0, 145.0, 155.0, 160.0, 170.0,
				175.0, 180.0, 190.0, 195.0, 205.0, 120.0, 135.0, 150.0,
				165.0, 178.0, 188.0, 200.0, 128.0, 142.0, 158.0, 172.0,
				185.0, 198.0, 210.0, 132.0, 148.0, 162.0
			>>)
		end

	study_hours_x: ARRAYED_LIST [REAL_64]
			-- Study hours (X-axis).
		do
			create Result.make_from_array (<<
				1.0, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0,
				6.5, 7.0, 7.5, 8.0, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5
			>>)
		end

	exam_scores_y: ARRAYED_LIST [REAL_64]
			-- Exam scores (Y-axis, correlated with study hours).
		do
			create Result.make_from_array (<<
				52.0, 58.0, 62.0, 68.0, 72.0, 75.0, 78.0, 82.0, 85.0, 88.0,
				90.0, 92.0, 94.0, 96.0, 55.0, 65.0, 70.0, 77.0, 84.0, 91.0
			>>)
		end

feature -- Histogram Data

	exam_scores_distribution: ARRAYED_LIST [REAL_64]
			-- 50 exam scores for histogram.
		do
			create Result.make_from_array (<<
				45.0, 52.0, 55.0, 58.0, 60.0, 62.0, 63.0, 65.0, 66.0, 67.0,
				68.0, 69.0, 70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 75.0, 76.0,
				77.0, 78.0, 79.0, 80.0, 80.0, 81.0, 82.0, 82.0, 83.0, 84.0,
				85.0, 85.0, 86.0, 87.0, 88.0, 88.0, 89.0, 90.0, 91.0, 92.0,
				93.0, 94.0, 95.0, 96.0, 97.0, 85.0, 78.0, 72.0, 68.0, 88.0
			>>)
		end

	response_times_ms: ARRAYED_LIST [REAL_64]
			-- API response times in milliseconds (skewed distribution).
		do
			create Result.make_from_array (<<
				12.0, 15.0, 18.0, 20.0, 22.0, 23.0, 25.0, 26.0, 28.0, 30.0,
				32.0, 35.0, 38.0, 40.0, 42.0, 45.0, 48.0, 52.0, 58.0, 65.0,
				72.0, 85.0, 95.0, 120.0, 150.0, 22.0, 24.0, 26.0, 28.0, 30.0,
				32.0, 34.0, 36.0, 38.0, 40.0, 42.0, 44.0, 46.0, 48.0, 50.0,
				55.0, 60.0, 68.0, 78.0, 90.0, 110.0, 140.0, 180.0, 250.0, 320.0
			>>)
		end

	age_distribution: ARRAYED_LIST [REAL_64]
			-- Customer ages for demographic analysis.
		do
			create Result.make_from_array (<<
				18.0, 19.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0,
				29.0, 30.0, 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 38.0, 40.0,
				42.0, 45.0, 48.0, 50.0, 52.0, 55.0, 58.0, 60.0, 62.0, 65.0,
				25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0, 33.0, 34.0,
				35.0, 36.0, 37.0, 38.0, 39.0, 40.0, 28.0, 32.0, 35.0, 42.0
			>>)
		end

feature -- Sparkline Data (mini time-series)

	cpu_usage_1min: ARRAYED_LIST [REAL_64]
			-- CPU usage percentages for 1 minute (60 samples).
		local
			l_i: INTEGER
			l_val: REAL_64
		do
			create Result.make (60)
			from l_i := 1 until l_i > 60 loop
				random.forth
				-- Simulate typical CPU usage: mostly 20-40%, occasional spikes
				l_val := 25.0 + random.double_item * 20.0
				if random.double_item > 0.9 then
					l_val := l_val + 30.0  -- Spike
				end
				Result.extend (l_val.min (100.0))
				l_i := l_i + 1
			end
		end

	memory_usage: ARRAYED_LIST [REAL_64]
			-- Memory usage over time (gradual increase with GC drops).
		local
			l_i: INTEGER
			l_val: REAL_64
		do
			create Result.make (30)
			l_val := 45.0
			from l_i := 1 until l_i > 30 loop
				random.forth
				l_val := l_val + random.double_item * 2.0
				if l_val > 80.0 then
					l_val := 50.0  -- GC collection
				end
				Result.extend (l_val)
				l_i := l_i + 1
			end
		end

	network_throughput: ARRAYED_LIST [REAL_64]
			-- Network throughput in Mbps.
		do
			create Result.make_from_array (<<
				45.0, 48.0, 52.0, 85.0, 92.0, 88.0, 75.0, 62.0, 55.0, 48.0,
				42.0, 38.0, 35.0, 40.0, 55.0, 72.0, 85.0, 90.0, 78.0, 65.0
			>>)
		end

	disk_io: ARRAYED_LIST [REAL_64]
			-- Disk I/O operations per second.
		do
			create Result.make_from_array (<<
				120.0, 125.0, 180.0, 250.0, 320.0, 280.0, 190.0, 145.0,
				130.0, 125.0, 160.0, 220.0, 180.0, 140.0, 135.0, 150.0
			>>)
		end

end
