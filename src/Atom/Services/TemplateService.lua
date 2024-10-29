local Template = {}
Template.__index = Template

function Template.new()
	local self = {}
	function self.Init()
		print("Atom TemplateService initialized.")
	end

	function self.Start()
		print("Atom TemplateService started.")
	end
	
	return self
end

function Template.hi()
	print("Hi")
end

return Template
