note
	description: "Test cases for simple_chart"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Tests

	test_creation
			-- Test that main class can be created.
		local
			l_obj: SIMPLE_CHART
		do
			create l_obj.make
			assert ("created", l_obj /= Void)
		end

end