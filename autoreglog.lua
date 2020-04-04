local hook = require("lib.samp.events")

local charset = {}  do
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.time())
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

local password = randomString(15);
local mail = randomString(10)..'@mail.ru';

local data = {
	['Ðåêëàìà ïîñòîðîííèõ ðåñóðñîâ'] = {1, -1, ''};
	['Äàííûé àêêàóíò {47C247}ñâîáîäåí{FFFFFF}'] = {1, -1, password};
	['{EFFF9E}Ïîâòîðèòå âàø ïàðîëü:'] = {1, -1, password};
	['{EFFF9E}Óêàæèòå âàøó.*ïî÷òó'] = {1, -1, mail};
	['{FFFF99}Âûáåðèòå âàø ïîë:'] = {1, -1, ''};
	['{FFFF99}Âûáåðèòå âàø öâåò êîæè:'] = {0, -1, ''};
	['{FFFF99}Âûáåðèòå íàöèîíàëüíîñòü:'] = {1, 1, ''};
	['{FFFFFF}Óêàæèòå âàø âîçðàñò'] = {1, -1, '25'};
	['Ïðè ââîäå ïðîìîêîäà âû ïîëó÷èòå îïðåäåëåííûå ïðåèìóùåñòâà íà ñòàðòå èãðû'] = {0, -1, 'bhjtbhjgrt'};
	['Äàííûé àêêàóíò {94FFA6}çàðåãèñòðèðîâàí{FFFFFF}'] = {1, -1, false}
}

local function getInfo()
	local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if res then
		local nick = sampGetPlayerNickname(id);
		local ip, port = sampGetCurrentServerAddress()
		return true, nick, ip;
	end
	return false, false, false;
end

local function addAccount()
	local res, nick, ip = getInfo()
	if res then
		local file = io.open(thisScript().directory..'\\accounts.txt', "a+");
		if file then
			file:write(nick..';'..password..';'..mail..';'..ip..'\n')
			file:close()
		end
	end
end

local function checkAccount()
	local res, nick, ip = getInfo()
	if res then
		local file = io.open(thisScript().directory..'\\accounts.txt', "r");
		if file then
			for line in file:lines() do
				if line:find(nick) and line:find(ip) then
					local password = line:match('.*;(.*);.*;'..ip)
					return password
				end
			end
			file:close()
		end
	end
	return false
end

local function chat(msg, type)
    if type == nil then type = true end
    local color = (type and '65f505' or 'f50575')
    local msg = msg:gsub('{color}', '{'..color..'}')
end

function hook.onShowDialog(id, style, title, btn1, btn2, text)
	for key, value in pairs(data) do
		if text:find(key) then
			if not value[3] then value[3] = checkAccount() end
			if value[3] then
				sampSendDialogResponse(id, value[1], value[2], value[3]);
				return false;
			end
		end
	end
end

function hook.onShowTextDraw(id, data)
	if data.text:find('PLAY') then
		sampSendClickTextdraw(id-1)
		addAccount()
	end
end
