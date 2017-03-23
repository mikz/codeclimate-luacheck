local format = require 'luacheck.format'
local cjson = require 'cjson'

local function Positions(line, column, end_column)
	return {
		begin = {
			line = line,
			column = column
		},
		['end'] = {
			line = line,
			column = end_column
		}
	}
end

local function OtherLocations(file, warning)
	if warning.prev_line then
		return {
			{
				path = file,
				positions = Positions(warning.line, warning.prev_column, warning.prev_column + warning.end_column - warning.column)
			}
		}
	end
end

local function Location(file, warning)
	return {
		path = file,
		positions = Positions(warning.line, warning.column, warning.end_column)

	}
end

local function Issue(file, warning)
	return {
		type = 'issue',
		check_name = warning.code,
		description = format.get_message(warning),
		categories = { 'Style' },
		location = Location(file, warning),
		other_locations = OtherLocations(file, warning),
	}
end
return function(report, file_names)
	-- CodeClimate formatter does not support any options for now
	local issues = {}

	for i, file_report in ipairs(report) do
		for _, warning in ipairs(file_report) do
			local issue = Issue(file_names[i], warning)
			io.stdout:write(cjson.encode(issue),string.char(0), "\n")
			table.insert(issues, issue)
		end
	end

	return ''
end
