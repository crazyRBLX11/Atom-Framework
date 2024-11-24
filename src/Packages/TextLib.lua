--!strict
-- Written by crazyattaker1. 29/10/2024. Lightweight RichText Implementation.
local TextLib = {}

type Properties = { Bold: boolean, StrikeThrough: boolean, Underline: boolean, Italics: boolean }

function TextLib.Update(Text: string, PropertiesTable: Properties)
	local BoldPrefix = ""
	local BoldSuffix = ""
	local StrikePrefix = ""
	local StrikeSuffix = ""
	local UnderlinePrefix = ""
	local UnderlineSuffix = ""
	local ItalicsPrefix = ""
	local ItalicsSuffix = ""
	if PropertiesTable.Bold == true then
		BoldPrefix = "<b>"
		BoldSuffix = "</b>"
	end
	if PropertiesTable.StrikeThrough == true then
		StrikePrefix = "<s>"
		StrikeSuffix = "</s>"
	end
	if PropertiesTable.Underline == true then
		UnderlinePrefix = "<u>"
		UnderlineSuffix = "</u>"
	end
	if PropertiesTable.Italics == true then
		ItalicsPrefix = "<i>"
		ItalicsSuffix = "</i>"
	end
	task.wait(1)
	return BoldPrefix
		.. StrikePrefix
		.. UnderlinePrefix
		.. ItalicsPrefix
		.. Text
		.. ItalicsSuffix
		.. UnderlineSuffix
		.. StrikeSuffix
		.. BoldSuffix
end

return TextLib
