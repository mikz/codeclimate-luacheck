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

local event_codes = {
	['0'] = { -- errors
		severity = 'blocker',
		categories = { 'Style', 'Compatibility' },
		minutes = 5
	},
	['1'] = { -- global variables
		severity = 'critical',
		categories = { 'Bug Risk', 'Clarity' },
		minutes = 15,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#global-variables]]
	},
	['2'] = { -- unused variables
		severity = 'minor',
		categories = { 'Clarity', 'Bug Risk' },
		minutes = 5,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#unused-variables-and-values]]
	},
	['3'] = { -- unused/uninitialized values
		severity = 'major',
		categories = { 'Clarity', 'Bug Risk' },
		minutes = 10,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#unused-variables-and-values]]
	},
	['4'] = { -- shadowing
		severity = 'minor',
		categories = { 'Clarity', 'Bug Risk' },
		minutes = 5,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#shadowing-declarations]]
	},
	['5'] = { -- unused code
		severity = 'minor',
		categories = { 'Clarity', 'Bug Risk' },
		minutes = 3,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#control-flow-and-data-flow-issues]]
	},
	['6'] = { -- whitespace
		severity = 'info',
		categories = { 'Style' },
		minutes = 1,
		description = [[https://luacheck.readthedocs.io/en/stable/warnings.html#formatting-issues]]
	},
}

local function event_info(event)
	return event_codes[event.code:sub(1,1)]
end

local function event_severity(event)
	return event_info(event).severity
end

local function event_description(event)
	return event_info(event).description
end

local function event_categories(event)
	return event_info(event).categories
end

local function event_remediation_points(event)
	return event_info(event).minutes * 10000
end

local function hash(s)
	return (s:gsub('.',function(s) return ('%2x'):format(s:byte(1)) end))
end

local function event_fingerprint(file, event)
	return hash(table.concat({file, event.code, event.column, event.end_column}, ':'))
end

local function Issue(file, warning)
	return {
		type = 'issue',
		check_name = warning.code,
		description = format.get_message(warning),
		categories = event_categories(warning),
		content = event_description(warning),
		severity = event_severity(warning),
		location = Location(file, warning),
		fingerprint = event_fingerprint(file, warning),
		other_locations = OtherLocations(file, warning),
		remediation_points = event_remediation_points(warning)
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
