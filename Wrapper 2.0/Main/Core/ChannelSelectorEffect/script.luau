--!strict
--!native
local core = {};
local coroutine = coroutine;
local game, workspace, print, warn, error ,assert, setmetatable, setfenv, getfenv, getmetatable, debug, Instance, newproxy, xpcall, typeof, type, table, rawset, rawget, unpack, next, tostring, string = game, workspace, print, warn, error, assert, setmetatable, setfenv, getfenv, getmetatable, debug, Instance, newproxy, xpcall, typeof, type, table, rawset, rawget, unpack, next, tostring, string;

local old = getfenv();
local shared = rawget(old, "shared");

setfenv(1, {});
setfenv(0, {});

local standard = {};
local c_functions = {};

local real_instances = {};
local lua_gc = {};

local renv = {}; 
xpcall(function()
	return game.."hi";	
end, function()
	standard.__concat = debug.info(2, "f");
end);
xpcall(function()
	return -game;	
end, function()
	standard.__unm = debug.info(2, "f");
end);
xpcall(function()
	return game + 1;	
end, function()
	standard.__add = debug.info(2, "f");
end);
xpcall(function()
	return game - 1;	
end, function()
	standard.__sub = debug.info(2, "f");
end);
xpcall(function()
	return game * 1;	
end, function()
	standard.__mul = debug.info(2, "f");
end);
xpcall(function()
	return game / 1;	
end, function()
	standard.__div = debug.info(2, "f");
end);
xpcall(function()
	return game // 1;	
end, function()
	standard.__idiv = debug.info(2, "f");
end);
xpcall(function()
	return game % 1;	
end, function()
	standard.__mod = debug.info(2, "f");
end);
xpcall(function()
	return game <= 1;	
end, function()
	standard.__le = debug.info(2, "f");
end);
xpcall(function()
	return game < 1;	
end, function()
	standard.__lt = debug.info(2, "f");
end);
xpcall(function()
	return #game;
end, function()
	standard.__len = debug.info(2, "f");
end);
xpcall(function()
	return game();
end, function()
	standard.__call = debug.info(2, "f");
end);
xpcall(function()
	for _, v in game do

	end
end, function()
	standard.__iter = debug.info(2, "f");
end);
standard.__metatable = getmetatable(game) :: "The metatable is locked";  


local c_proxies: {[any]: any} = {};
local metatables: {[any]: {[string]: any}} = {};

local illegal_fetch = {};
@native function core.SetType(self: any, proxy: any, type_of: string): ()
	if not c_proxies[proxy] then
		return;
	end;
	local mt = metatables[proxy];

	rawset(mt, "__type", type_of)
	return;
end;
local search; search = function(to_scan: {[any]: any}, target: (...any) -> (...any), hook: (...any) -> (...any))
	for i,v in to_scan do
		if type(v) == "function" and v == target then
			rawset(to_scan, i, hook);
		--	to_scan[i] = hook;
			break;
		elseif type(v) == "table" then
			search(v, target, hook);
		end;
	end;
end;
core.exploit_lib = {
	newcclosure = function(f: (...any) -> (...any)): (...any) -> (...any)
		table.insert(c_functions, f);
		return f;
	end,	
	getgc = function(operand: boolean): {[any]: any}
		local fake_gc = {} :: {[any]: any};
		for i: any, v: any in lua_gc do
			if operand and type(v) == "table" or type(v) == "userdata" then fake_gc[i] = v; continue; end;
			fake_gc[i] = v;
		end; 
		return fake_gc;
	end,
	getrawmetatable = function(operand: any)
		return metatables[operand] or getmetatable(operand)
	end,
	iscproxy = function(operand: any): boolean
		return c_proxies[operand] ~= nil 
	end,
	hookfunction = function(target: (...any) -> (...any), hook: (...any) -> (...any)): (...any) -> (...any)
		search(renv, target, hook);
		search(lua_gc, hook, target);
		return target;
	end,
};
local newcclosure = core.exploit_lib.newcclosure;

local decode_args = @native function(special: boolean, ...: any): {[number]: any}
	local args: {any} = {...};
	for i: number, v: any in args do
		args[i] = if type(v) == "userdata" and typeof(v) == "userdata" then (real_instances[v] or (special and workspace) or v) else v;
		--args[i] = type(v) == "userdata" and typeof(v) == "userdata" or special and workspace or real_instances[v] or v;
	end;
	return args;
end;
local encode_args = @native function(speical: boolean, ...: any): {[number]: any}
	local args: {any} = {...};
	for i: number, v: any in args do
		args[i] = if type(v) == "userdata" and typeof(v) == "Instance" then core:ReplicateInstance(v) else v;
	end;
	return args;
end;

@native function core.protect_from_debug_info(fake_func: (...any) -> (...any) , real_func: (...any) -> (...any) ): (...any) -> (...any)
	if not fake_func or not real_func then
		return fake_func or function() end;
	end;
	illegal_fetch[real_func] = fake_func;
	return fake_func;
end;
@native function core.CreateCMetaMethods(self: any, special: boolean, proxy: any): ()
	local metatable = getmetatable(proxy) ::  typeof(standard);	
	metatable.__iter = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__iter(unpack(decode_args(special, ...)))));
	end);

	metatable.__div = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__div(unpack(decode_args(special, ...)))));
	end);
	metatable.__unm = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__unm(unpack(decode_args(special, ...)))));
	end);

	metatable.__call = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__call(unpack(decode_args(special, ...)))));
	end);
	metatable.__concat = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__concat(unpack(decode_args(special, ...)))));
	end);

	metatable.__lt = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__lt(unpack(decode_args(special, ...)))));
	end);
	metatable.__mul = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__mul(unpack(decode_args(special, ...)))));
	end);

	metatable.__add = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__add(unpack(decode_args(special, ...)))));
	end);
	metatable.__len = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__len(unpack(decode_args(special, ...)))));
	end);

	metatable.__sub = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__sub(unpack(decode_args(special, ...)))));
	end);
	metatable.__idiv = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__idiv(unpack(decode_args(special, ...)))));
	end);

	metatable.__le = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__le(unpack(decode_args(special, ...)))));

	end);
	metatable.__mod = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(special, metatable.__mod(unpack(decode_args(special, ...)))));
	end);

	for i: any, v: any in metatable do
		if type(v) == "function" then
			--print(standard[i], i);
			core.protect_from_debug_info(v, standard[i]);
		end;
	end;
	metatable.__metatable = metatable.__metatable;
	return;
end;
@native function core.CreateCProxy(self: any, is_non_replicated: boolean): (any, typeof(standard) & {[string]: any})
	local proxy: any = newproxy(true);
	local mt = getmetatable(proxy) :: typeof(standard) & {[string]: any};


	core:CreateCMetaMethods(is_non_replicated, proxy);
	c_proxies[proxy] = true;

	metatables[proxy] = mt;
	return proxy, mt;
end;

type instance_metatable = typeof(standard) & {
	__index: (...any) -> (...any);
	__namecall: (...any) -> (...any);
	__newindex: (...any) -> (...any);
	__tostring: (...any) -> (...any);
	__type: string;
};

@native function core.ReplicateInstance(self: any, obj: any): any
	if real_instances[obj] then
		return real_instances[obj];
	end;

	local proxy: any, metatable: instance_metatable = core:CreateCProxy(false);
	local instance_type: string = typeof(obj);

	core:SetType(proxy, instance_type);
	real_instances[proxy] = obj;

	local real_methods = {};
	xpcall(@native function()
		return obj.hi;
	end, @native function()
		real_methods.__index = debug.info(2, "f");
	end);
	xpcall(function()
		obj.Name = newproxy();
	end,function()
		real_methods.__newindex = debug.info(2, "f");
	end);
	xpcall(function()
		return obj:______();
	end, function()
		real_methods.__namecall = debug.info(2, "f");
	end);
	xpcall(function()
		return tostring(rawget(old, "script"));
	end, function()
		real_methods.__tostring = debug.info(2, "f");
	end);
	
	local newcclosure = core.exploit_lib.newcclosure;
	metatable.__index = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(false, real_methods.__index(unpack(decode_args(false, ...)))));
	end);
	
	metatable.__namecall = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(false, real_methods.__namecall(unpack(decode_args(false, ...)))));
	end);
	metatable.__newindex = newcclosure(@native function(...: any): ...any 
		encode_args(false, real_methods.__newindex(unpack(decode_args(false, ...))));
		return;
	end);
	
	metatable.__tostring = newcclosure(@native function(...: any): ...any 
		return unpack(encode_args(false, real_methods.__tostring(unpack(decode_args(false, ...)))));
	end);

	for i: any, v: any in metatable do
		if type(v) == 'function' then
			core.protect_from_debug_info(v, real_methods[i]);
		end;
	end;
	return proxy;
end;

local el_globals: {[string]: number} = {["DockWidgetPluginGuiInfo"] = 1, ["warn"] = 2, ["tostring"] = 3, ["gcinfo"] = 4, ["os"] = 5, ["tick"] = 6, ["task"] = 7, ["getfenv"] = 8, ["debug"] = 9, ["NumberSequence"] = 10, ["assert"] = 11, ["rawlen"] = 12, ["tonumber"] = 13, ["CommandData"] = 14, ["Color3"] = 15, ["Enum"] = 16, ["Delay"] = 17, ["OverlapParams"] = 18, ["Path2DControlPoint"] = 19, ["SecurityCapabilities"] = 20, ["AdReward"] = 21, ["vector"] = 22, ["ypcall"] = 23, ["coroutine"] = 24, ["DateTime"] = 25, ["NumberRange"] = 26, ["buffer"] = 27, ["PhysicalProperties"] = 28, ["elapsedTime"] = 29, ["version"] = 30, ["PluginManager"] = 31, ["Stats"] = 32, ["stats"] = 33, ["Ray"] = 34, ["NumberSequenceKeypoint"] = 35, ["Version"] = 36, ["Vector2"] = 37, ["UserSettings"] = 38, ["Game"] = 39, ["Content"] = 40, ["spawn"] = 41, ["settings"] = 42, ["string"] = 43, ["xpcall"] = 44, ["loadstring"] = 45, ["printidentity"] = 46, ["FloatCurveKey"] = 47, ["print"] = 48, ["delay"] = 49, ["Wait"] = 50, ["wait"] = 51, ["RaycastParams"] = 52, ["unpack"] = 53, ["TweenInfo"] = 54, ["ElapsedTime"] = 55, ["require"] = 56, ["Vector3"] = 57, ["time"] = 58, ["Vector3int16"] = 59, ["setmetatable"] = 60, ["next"] = 61, ["Workspace"] = 62, ["UDim2"] = 63, ["RotationCurveKey"] = 64, ["ipairs"] = 65, ["Font"] = 66, ["CatalogSearchParams"] = 67, ["rawequal"] = 68, ["Region3int16"] = 69, ["collectgarbage"] = 70, ["game"] = 71, ["getmetatable"] = 72, ["Spawn"] = 73, ["PluginDrag"] = 74, ["Region3"] = 75, ["utf8"] = 76, ["Random"] = 77, ["CellId"] = 78, ["rawset"] = 79, ["PathWaypoint"] = 80, ["CFrame"] = 81, ["_VERSION"] = 82, ["UDim"] = 83, ["workspace"] = 84, ["table"] = 85, ["math"] = 86, ["bit32"] = 87, ["pcall"] = 88, ["pairs"] = 89, ["ColorSequenceKeypoint"] = 90, ["type"] = 91, ["typeof"] = 92, ["SharedTable"] = 93, ["select"] = 94, ["Vector2int16"] = 95, ["ColorSequence"] = 96, ["rawget"] = 97, ["newproxy"] = 98, ["Rect"] = 99, ["BrickColor"] = 100, ["setfenv"] = 101, ["Instance"] = 102, ["Axes"] = 103, ["error"] = 104, ["Faces"] = 105};


local init: boolean = false;
@native function core.insertgc(value: any)
	table.insert(lua_gc, value);
end;


@native function core.sandbox(self: any, custom: {[string]: any}?): any
	local caller = getfenv(2);
	if not init then
		for i: string, v: number in el_globals do
			renv[i] = caller[i];
		end;
		init = true;
	end;

	local fake_env = {
		["script"] = core:ReplicateInstance(rawget(caller, "script"));
		["_G"] = {};
		["shared"] = {};
	};
	setmetatable(fake_env, {});
	local raw_mt = getmetatable(fake_env);

	metatables[fake_env] = raw_mt;
	raw_mt.__index = newcclosure(@native function(self, index): any?
		if not index or type(index) ~= "string" then return nil; end;
		return custom and rawget(custom, index) or renv[index];
	end);

	raw_mt.__metatable = standard.__metatable;
	return fake_env;
end;
local e = {};
setmetatable(e, {
	__index = @native function(self: any, index: any)
		return rawget(core, index);
	end,
	__newindex = @native function(): ()
		return;
	end,	
});
table.freeze(e);
rawset(getmetatable(e), "__metatable", '');

--getmetatable(e).__metatable = ''
rawset(shared, "core", e);

return core;