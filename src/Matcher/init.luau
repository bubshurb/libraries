-- #selene: allow(unused_variable)

--[=[
	@class Matcher

	7kayoh's matcher  module ported to wally.
]=]

-- Matcher.lua
-- A matcher module that provides easy and advanced matching of strings.
-- 7kayoh
-- Jan 27, 2022

-- Original authors:
-- Copyright 2011-2012 Nils Nordman <nino at nordman.org>
-- Copyright 2012-2014 Robert Gieseke <rob.g@web.de>

type Explanation = {
	score: number,
	start_pos: number,
	end_pos: number,
	[number]: { start_pos: number, length: number },
}

local append = table.insert

local Matcher = {}

--[[ Constructs a new matcher.
@param candidates The candidates to consider for matching. A table of either
string, or tables containing strings.
@param search_case_insensitive Whether searches are case insensitive or not.
Defaults to `true`.
@param search_fuzzy Whether fuzzy searching should be used in addition to
explicit matching. Defaults to `true`.
]]
function Matcher.new(
	candidates: { string | { string } },
	search_case_insensitive: boolean?,
	search_fuzzy: boolean?
)
	local m = {
		search_case_insensitive = search_case_insensitive,
		search_fuzzy = search_fuzzy,
	}
	setmetatable(m, { __index = Matcher })
	m:setCandidates(candidates)
	return m
end

-- Applies search matchers on a line.
-- @param line The line to match
-- @param matchers The search matchers to apply
-- @return A numeric score if the line matches or nil otherwise. For scoring,
-- lower is better.
local function match_score(line: string, matchers: { (string) -> number }): number?
	local score = 0

	for _, matcher in ipairs(matchers) do
		local matcher_score = matcher(line)
		if not matcher_score then
			return nil
		end
		score = score + matcher_score
	end
	return score
end

--[[ Explains the match for a given search.
@param search The search string to match
@param text The text to match against
@return A list of explanation tables. Each explanation table contains the
following fields:
  `score`: The score for the match
  `start_pos`: The start position of the best match
  `end_pos`: The end position of the best match
  `1..n`: Tables of matching positions with the field start_pos and length
]]
function Matcher:explain(search: string, text: string): { Explanation }
	if not search or #search == 0 then
		return {}
	end
	if self.search_case_insensitive then
		search = search:lower()
		text = text:lower()
	end
	local matchers = self:_matchers_for_search(search)
	local explanations = {}

	for _, matcher in ipairs(matchers) do
		local score, start_pos, end_pos, newSearch = matcher(text)
		if not score then
			return {}
		end
		local explanation = { score = score, start_pos = start_pos, end_pos = end_pos }
		local s_index = 1
		local l_start, l_index = start_pos, start_pos
		while s_index <= #newSearch do
			repeat
				s_index = s_index + 1
				l_index = l_index + 1
			until newSearch:sub(s_index, s_index) ~= text:sub(l_index, l_index)
				or s_index > #newSearch
			append(explanation, { start_pos = l_start, length = l_index - l_start })
			if s_index > #newSearch then
				break
			end
			repeat
				l_index = l_index + 1
			until newSearch:sub(s_index, s_index) == text:sub(l_index, l_index) or l_index > end_pos
			l_start = l_index
		end
		append(explanations, explanation)
	end

	return explanations
end

function Matcher:destroy()
	setmetatable(self, nil)
end

-- Matches search against the candidates.
-- @param search The search string to match
-- @return A table of matching candidates, ordered by relevance.
function Matcher:match(search: string): { string }
	if not search or #search == 0 then
		return self.candidates
	end
	local cache = self.cache
	if self.search_case_insensitive then
		search = search:lower()
	end
	local matches = cache.matches[search] or {}
	if #matches > 0 then
		return matches
	end
	local lines = cache.lines[string.sub(search, 1, -2)] or self.lines
	local matchers = self:_matchers_for_search(search)

	local matching_lines = {}
	for i, line in ipairs(lines) do
		local score = match_score(line.text, matchers)
		if score then
			matches[#matches + 1] = { index = line.index, score = score }
			matching_lines[#matching_lines + 1] = line
		end
	end
	cache.lines[search] = matching_lines

	table.sort(matches, function(a, b)
		return a.score < b.score
	end)
	local matching_candidates = {}
	for _, match in ipairs(matches) do
		matching_candidates[#matching_candidates + 1] = self.candidates[match.index]
	end
	self.cache.matches[search] = matching_candidates
	return matching_candidates
end

function Matcher:setCandidates(candidates: { string | { string } })
	self.candidates = candidates
	self.cache = {
		lines = {},
		matches = {},
	}
	local lines = {}
	local fuzzy_score_penalty = 0

	for i, candidate in ipairs(candidates) do
		if type(candidate) ~= "table" then
			candidate = { candidate }
		end
		local text = table.concat(candidate, " ")
		if self.search_case_insensitive then
			text = text:lower()
		end
		lines[#lines + 1] = {
			text = text,
			index = i,
		}
		fuzzy_score_penalty = math.max(fuzzy_score_penalty, #text)
	end
	self.lines = lines
	self.fuzzy_score_penalty = fuzzy_score_penalty
end

local pattern_escapes: { [string]: string } = {}
for c in string.gmatch("^$()%.[]*+-?", ".") do
	pattern_escapes[c] = "%" .. c
end

local function fuzzy_search_pattern(search: string)
	local pattern = ""
	for i = 1, #search do
		local c = search:sub(i, i)
		c = pattern_escapes[c] or c
		pattern = pattern .. c .. ".-"
	end
	return pattern
end

--- Creates matches for the specified search
-- @param search_string The search string
-- @return A table of matcher functions, each taking a line as parameter and
-- returning a score (or nil for no match).
function Matcher:_matchers_for_search(search_string: string): { (string) -> number? }
	local fuzzy = self.search_fuzzy
	local fuzzy_penalty = self.fuzzy_score_penalty
	local groups = {}
	for part in search_string:gmatch("%S+") do
		groups[#groups + 1] = part
	end
	local matchers = {}

	for _, search in ipairs(groups) do
		local fuzzy_pattern = fuzzy and fuzzy_search_pattern(search)
		matchers[#matchers + 1] = function(line)
			local start_pos, end_pos = line:find(search, 1, true)
			local score = start_pos
			if not start_pos and fuzzy then
				start_pos, end_pos = line:find(fuzzy_pattern)
				if start_pos then
					score = (end_pos - start_pos) + fuzzy_penalty
				end
			end
			if score then
				return score + #line, start_pos, end_pos, search
			end

			return nil
		end
	end
	return matchers
end

return Matcher
