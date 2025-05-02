--[[
	#302@abcdefg233  #305@Mirtle

	Automatic capitalization English vocabulary：
	- Some rules do not convert
	- Enter the initial capitalization, and convert the candidate words to the initial capitalization： Hello → Hello
	- At least before entering 2 Caps for letters, convert candidate words to all capitals： HEllo → HELLO

    Can't dynamically adjust word frequency when capitalized
--]]
local function autocap_filter(input, env)
    local code = env.engine.context.input -- 输入码
    local codeLen = #code
    local codeAllUCase = false
    local codeUCase = false
    -- No conversion：
    if codeLen == 1 or       -- Code length 1
        code:find("^[%l%p]") -- The first digit of the input code is lowercase letters or punctuation
    then                     -- The input code does not meet the conditions and does not determine the candidate option
        for cand in input:iter() do
            yield(cand)
        end
        return
    ---- Input code in full capital
    -- elseif code == code:upper() then
    --     codeAllUCase = true
    -- Before entering the code 2 - n Caps
    elseif code:find("^%u%u+.*") then
        codeAllUCase = true
    -- Input code first capitalization
    elseif code:find("^%u.*") then
        codeUCase = true
    end

    local pureCode = code:gsub("[%s%p]", "")     -- Delete input codes for punctuation and spaces
    for cand in input:iter() do
        local text = cand.text                   -- Candidate words
        local pureText = text:gsub("[%s%p]", "") -- Delete candidate words for punctuation and spaces
        -- 不转换：
        if
            text:find("[^%w%p%s]") or                 -- Candidates contain non-letters and numbers, non-punctuation marks, non-space characters
            text:find("%s") or                        -- Candidate words contain spaces
            pureText:find("^" .. code) or             -- The input code exactly matches the candidate words
            (cand.type ~= "completion" and            -- Words are inconsistent with their corresponding codes
                pureCode:lower() ~= pureText:lower()) -- For example PS - Photoshop
        then
            yield(cand)
        -- Before entering the code 2~10 Position capitalization, candidate words are converted to full capitalization
        elseif codeAllUCase then
            text = text:upper()
            yield(Candidate(cand.type, 0, codeLen, text, cand.comment))
        -- The first capitalization of the input code is converted to the first capitalization of the candidate word
        elseif codeUCase then
            text = text:gsub("^%a", string.upper)
            yield(Candidate(cand.type, 0, codeLen, text, cand.comment))
        else
            yield(cand)
        end
    end
end

return autocap_filter
