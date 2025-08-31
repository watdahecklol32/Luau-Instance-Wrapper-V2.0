local rawget = rawget;
repeat task.wait() until rawget(shared, "core");
do
	local core = rawget(shared, "core");
	
	local rules = {
		game = core:ReplicateInstance(game);
		Game = core:ReplicateInstance(Game);
		
		workspace = core:ReplicateInstance(workspace);
		Workspace = core:ReplicateInstance(Workspace);
	};
	
	local env_sandbox = core:sandbox(rules);
	local getrawmetatable: (object: any) -> (any) = core.exploit_lib.getrawmetatable;
	
	local hookfunction: (target: func, hook: func) -> (func) = core.exploit_lib.hookfunction;
	local newcclosure: (func, string?) -> func = core.exploit_lib.newcclosure;
	
	local iscproxy: (operand: any) -> boolean = core.exploit_lib.iscproxy;
	
	local hook; hook = hookfunction(typeof, newcclosure(@native function(operand: any)
		if type(operand) == "userdata" and hook(operand) == "userdata" and iscproxy(operand) then
			return rawget(getrawmetatable(operand), "__type") or hook(operand);
		end;
		return hook(operand);
	end));
	
	setfenv(1, env_sandbox);
	setfenv(0, env_sandbox);
	
	print(typeof(game))
end;