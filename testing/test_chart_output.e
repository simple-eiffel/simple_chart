note
	description: "[
		Tests that generate SVG images and PDF documents from charts.
		Outputs saved to testing/output/ for verification.
	]"
	author: "Claude + Larry"
	date: "2026-01-24"

class
	TEST_CHART_OUTPUT

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize test suite.
		do
			create chart.make
			create data.make
			create svg.make
			create png.make
			create pdf.make
			pdf.use_chrome  -- Use Edge/Chrome for PDF generation
			output_dir := "testing/output/"
		end

feature -- Access

	chart: SIMPLE_CHART
			-- Chart facade.

	data: TEST_DATA_GENERATOR
			-- Test data generator.

	svg: SVG_CHART_RENDERER
			-- SVG renderer.

	png: CAIRO_CHART_RENDERER
			-- PNG renderer using Cairo.

	pdf: SIMPLE_PDF
			-- PDF generator.

	output_dir: STRING
			-- Output directory path.

feature -- SVG Image Tests

	test_svg_bar_chart
			-- Generate SVG bar chart.
		local
			l_labels: ARRAYED_LIST [STRING]
			l_values: ARRAYED_LIST [REAL_64]
		do
			l_labels := data.monthly_sales_labels
			l_values := data.monthly_sales_values
			svg.set_title ("Monthly Sales")
			svg.set_size (700, 400)
			svg.render_bar_chart (l_labels, l_values)
			write_svg ("chart_bar_sales.svg", svg.output)
			check not svg.output.is_empty end
		end

	test_svg_line_chart
			-- Generate SVG line chart.
		do
			svg.set_title ("Stock Price - 30 Days")
			svg.set_size (700, 400)
			svg.render_line_chart (data.stock_prices_30_days)
			write_svg ("chart_line_stock.svg", svg.output)
			check not svg.output.is_empty end
		end

	test_svg_scatter_plot
			-- Generate SVG scatter plot.
		do
			svg.set_title ("Height vs Weight")
			svg.set_size (600, 500)
			svg.render_scatter (data.height_weight_x, data.height_weight_y)
			write_svg ("chart_scatter_hw.svg", svg.output)
			check not svg.output.is_empty end
		end

	test_svg_histogram
			-- Generate SVG histogram.
		do
			svg.set_title ("Exam Score Distribution")
			svg.set_size (700, 400)
			svg.render_histogram (data.exam_scores_distribution, 10)
			write_svg ("chart_histogram_exam.svg", svg.output)
			check not svg.output.is_empty end
		end

	test_svg_multi_chart_page
			-- Generate HTML page with multiple SVG charts.
		local
			l_html: STRING
		do
			create l_html.make (10000)
			l_html.append ("<!DOCTYPE html><html><head>")
			l_html.append ("<title>Chart Gallery</title>")
			l_html.append ("<style>body{font-family:Arial,sans-serif;margin:20px;background:#f5f5f5}")
			l_html.append (".chart{background:white;margin:20px 0;padding:20px;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,0.1)}")
			l_html.append ("h1{color:#333}h2{color:#666;border-bottom:1px solid #ddd;padding-bottom:10px}</style>")
			l_html.append ("</head><body>")
			l_html.append ("<h1>SIMPLE_CHART Gallery</h1>")

			-- Bar chart
			l_html.append ("<div class=%"chart%"><h2>Bar Chart: Monthly Sales</h2>")
			svg.set_title ("")
			svg.set_size (650, 350)
			svg.render_bar_chart (data.monthly_sales_labels, data.monthly_sales_values)
			l_html.append (svg.output)
			l_html.append ("</div>")

			-- Line chart
			l_html.append ("<div class=%"chart%"><h2>Line Chart: Stock Price Trend</h2>")
			svg.set_size (650, 300)
			svg.render_line_chart (data.stock_prices_30_days)
			l_html.append (svg.output)
			l_html.append ("</div>")

			-- Scatter plot
			l_html.append ("<div class=%"chart%"><h2>Scatter Plot: Height vs Weight</h2>")
			svg.set_size (550, 400)
			svg.render_scatter (data.height_weight_x, data.height_weight_y)
			l_html.append (svg.output)
			l_html.append ("</div>")

			-- Histogram
			l_html.append ("<div class=%"chart%"><h2>Histogram: Exam Scores</h2>")
			svg.set_size (650, 300)
			svg.render_histogram (data.exam_scores_distribution, 10)
			l_html.append (svg.output)
			l_html.append ("</div>")

			l_html.append ("</body></html>")

			write_file ("chart_gallery.html", l_html)
			check not l_html.is_empty end
		end

feature -- PNG Image Tests (Cairo)

	test_png_bar_chart
			-- Generate PNG bar chart using Cairo.
		do
			png.set_title ("Monthly Sales")
			png.set_size (800, 500)
			png.render_bar_chart (data.monthly_sales_labels, data.monthly_sales_values, output_dir + "chart_bar_sales.png")
			check png.last_error.is_empty end
		end

	test_png_line_chart
			-- Generate PNG line chart using Cairo.
		do
			png.set_title ("Stock Price - 30 Days")
			png.set_size (800, 500)
			png.render_line_chart (data.stock_prices_30_days, output_dir + "chart_line_stock.png")
			check png.last_error.is_empty end
		end

	test_png_scatter_plot
			-- Generate PNG scatter plot using Cairo.
		do
			png.set_title ("Height vs Weight Correlation")
			png.set_size (700, 600)
			png.render_scatter (data.height_weight_x, data.height_weight_y, output_dir + "chart_scatter_hw.png")
			check png.last_error.is_empty end
		end

	test_png_histogram
			-- Generate PNG histogram using Cairo.
		do
			png.set_title ("Exam Score Distribution")
			png.set_size (800, 500)
			png.render_histogram (data.exam_scores_distribution, 10, output_dir + "chart_histogram_exam.png")
			check png.last_error.is_empty end
		end

feature -- PDF Tests

	test_pdf_chart_report
			-- Generate PDF report with charts.
		local
			l_html: STRING
			l_doc: SIMPLE_PDF_DOCUMENT
		do
			if pdf.is_available then
				create l_html.make (8000)
				l_html.append ("<!DOCTYPE html><html><head>")
				l_html.append ("<title>Chart Report</title>")
				l_html.append ("<style>")
				l_html.append ("body{font-family:Arial,sans-serif;margin:30px;}")
				l_html.append ("h1{color:#2c3e50;text-align:center;}")
				l_html.append ("h2{color:#34495e;margin-top:30px;}")
				l_html.append (".chart{margin:20px 0;}")
				l_html.append ("</style></head><body>")

				l_html.append ("<h1>SIMPLE_CHART Report</h1>")
				l_html.append ("<p style=%"text-align:center;color:#7f8c8d%">Generated by simple_chart library</p>")

				-- Bar chart
				l_html.append ("<h2>Monthly Sales Performance</h2>")
				l_html.append ("<div class=%"chart%">")
				svg.set_title ("")
				svg.set_size (500, 300)
				svg.render_bar_chart (data.monthly_sales_labels, data.monthly_sales_values)
				l_html.append (svg.output)
				l_html.append ("</div>")

				-- Line chart
				l_html.append ("<h2>Stock Price Trend (30 Days)</h2>")
				l_html.append ("<div class=%"chart%">")
				svg.set_size (500, 250)
				svg.render_line_chart (data.stock_prices_30_days)
				l_html.append (svg.output)
				l_html.append ("</div>")

				-- Histogram
				l_html.append ("<h2>Exam Score Distribution</h2>")
				l_html.append ("<div class=%"chart%">")
				svg.set_size (500, 250)
				svg.render_histogram (data.exam_scores_distribution, 10)
				l_html.append (svg.output)
				l_html.append ("</div>")

				l_html.append ("</body></html>")

				pdf.set_page_size ("Letter")
				pdf.set_margins ("0.75in")
				l_doc := pdf.from_html (l_html)
				if l_doc.is_valid and then l_doc.save_to_file (output_dir + "chart_report.pdf") then
					-- PDF saved successfully
				end
				check l_doc.is_valid end
			end
		end

	test_pdf_dashboard
			-- Generate PDF dashboard with multiple charts.
		local
			l_html: STRING
			l_doc: SIMPLE_PDF_DOCUMENT
		do
			if pdf.is_available then
				create l_html.make (10000)
				l_html.append ("<!DOCTYPE html><html><head>")
				l_html.append ("<title>Dashboard</title>")
				l_html.append ("<style>")
				l_html.append ("body{font-family:Arial,sans-serif;margin:20px;}")
				l_html.append ("h1{color:#2c3e50;text-align:center;margin-bottom:30px;}")
				l_html.append (".grid{display:flex;flex-wrap:wrap;gap:20px;}")
				l_html.append (".cell{flex:1;min-width:45%%;background:#fff;padding:15px;border:1px solid #ddd;border-radius:5px;}")
				l_html.append (".cell h3{margin:0 0 10px 0;color:#34495e;font-size:14px;}")
				l_html.append ("</style></head><body>")

				l_html.append ("<h1>Executive Dashboard</h1>")
				l_html.append ("<div class=%"grid%">")

				-- Chart 1: Sales
				l_html.append ("<div class=%"cell%"><h3>Sales by Month</h3>")
				svg.set_size (350, 220)
				svg.render_bar_chart (data.monthly_sales_labels, data.monthly_sales_values)
				l_html.append (svg.output)
				l_html.append ("</div>")

				-- Chart 2: Stock
				l_html.append ("<div class=%"cell%"><h3>Stock Performance</h3>")
				svg.set_size (350, 220)
				svg.render_line_chart (data.stock_prices_30_days)
				l_html.append (svg.output)
				l_html.append ("</div>")

				-- Chart 3: Scatter
				l_html.append ("<div class=%"cell%"><h3>Correlation Analysis</h3>")
				svg.set_size (350, 220)
				svg.render_scatter (data.study_hours_x, data.exam_scores_y)
				l_html.append (svg.output)
				l_html.append ("</div>")

				-- Chart 4: Histogram
				l_html.append ("<div class=%"cell%"><h3>Score Distribution</h3>")
				svg.set_size (350, 220)
				svg.render_histogram (data.exam_scores_distribution, 8)
				l_html.append (svg.output)
				l_html.append ("</div>")

				l_html.append ("</div></body></html>")

				pdf.set_page_size ("Letter")
				pdf.set_orientation ("Landscape")
				pdf.set_margins ("0.5in")
				l_doc := pdf.from_html (l_html)
				if l_doc.is_valid and then l_doc.save_to_file (output_dir + "chart_dashboard.pdf") then
					-- PDF saved successfully
				end
				check l_doc.is_valid end
			end
		end

feature {NONE} -- File Output

	write_svg (a_filename: STRING; a_content: STRING)
			-- Write SVG file.
		local
			l_file: SIMPLE_FILE
			l_ok: BOOLEAN
		do
			create l_file.make (output_dir + a_filename)
			l_ok := l_file.write_all (a_content)
		end

	write_file (a_filename: STRING; a_content: STRING)
			-- Write text file.
		local
			l_file: SIMPLE_FILE
			l_ok: BOOLEAN
		do
			create l_file.make (output_dir + a_filename)
			l_ok := l_file.write_all (a_content)
		end

end
