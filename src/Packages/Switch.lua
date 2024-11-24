local bypassIndex = math.huge -- As a heads up, NEVER set your case value to this. It will break things!

local self
self = {
	[1] = function(condition) -- Switch
		-- The first thing we want to do is get that condition, and NOT call the case function, so we will just
		-- return another function with the functionality of a case

		return function(cases)
			for index, case in ipairs(cases) do
				local conditionResult, caseFunction = case(condition)

				if typeof(conditionResult) == "function" then
					-- If conditionResult is a function, we can assume we just came across a default statement

					if index ~= #cases then
						error("Attempted to use a default statement in an index that was not the last")
					else
						conditionResult()
						break
					end
				elseif typeof(conditionResult) == "boolean" then
					-- If conditionResult is a boolean, we can assume we just came across a case statement

					if conditionResult then
						if caseFunction then
							-- If the case has its own defined function, immediately call it

							caseFunction()
						else
							-- Otherwise, let's look for the next case attached to a function

							while true do
								index += 1

								if cases[index] == self[3] then
									warn(
										"Case "
											.. condition
											.. " does not ever break, and ends in a default statement. Did you forget to include a function somewhere?"
									)
									break
								end

								local _, newCaseFunction = cases[index](bypassIndex)

								if newCaseFunction then
									newCaseFunction()
									break
								elseif index > #cases then
									warn(
										"Case "
											.. condition
											.. " does not ever break. Did you forget to include a function somewhere?"
									)
									break
								end
							end
						end

						break
					end
				else
					-- We should expect cases to return a boolean userdata value, and a function userdata value for default statements
					-- Anything else is unacceptable because its not a compatible statement

					error("Attempted to use a non-valid statement in the switch statement")
				end
			end
		end
	end,

	[2] = function(requiredValue) -- Case
		-- The first thing we want is to get the checked comparison
		-- Of course, we don't want to run the case function, so let's
		-- return a parent function

		return function(caseFunction)
			return function(conditionValue)
				-- In here, we check if the condition meets the case required value
				-- If so, the switch statement will recognize this by recieving a
				-- true value, and this finding the first occuring attached function.
				-- If not, the switch statement will recieve a false value and ignore
				-- the case.

				if conditionValue == bypassIndex or conditionValue == requiredValue then
					return true, caseFunction
				else
					return false, nil
				end
			end
		end
	end,

	[3] = function() -- Default
		-- This works almost exactly like a case, except we do not check a condition
		-- This is similar to an "else" statement in lua/luau

		return function(defaultFunction)
			return function()
				return defaultFunction
			end
		end
	end,
}

return self
