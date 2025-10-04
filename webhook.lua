return function(HttpService, webhookURL, ctx)
	local plr = ctx.player
	if not plr or type(webhookURL) ~= "string" or #webhookURL == 0 then return end

	local function iso(t) return os.date("!%Y-%m-%dT%H:%M:%SZ", t or os.time()) end
	local uid = tonumber(plr.UserId) or 0
	local profile = ("https://www.roblox.com/users/%d/profile"):format(uid)
	local nowSend = os.time()
	local whenHit = tonumber(ctx.detected_unix) or nowSend

	local embed = {
		title = "Remote Misuse Detected",
		description = ("**Remote:** `%s`\n**Reason:** `%s`\n**UUID:** `%s`")
			:format(tostring(ctx.remote or "?"), tostring(ctx.reason or "?"), tostring(ctx.uuid or "-")),
		color = 15158332,
		fields = {
			{ name = "UserID", value = tostring(uid), inline = true },
			{ name = "Username", value = tostring(plr.Name), inline = true },
			{ name = "DisplayName", value = tostring(plr.DisplayName), inline = true },
			{ name = "Account Age (days)", value = tostring(plr.AccountAge or 0), inline = true },
			{ name = "Profile", value = profile, inline = false },
			{ name = "Detected At (UTC)", value = iso(whenHit), inline = true },
			{ name = "Webhook Sent (UTC)", value = iso(nowSend), inline = true },
		},
		timestamp = iso(nowSend)
	}

	local payload = {
		username = "Abyss Guardian",
		embeds = { embed }
	}

	local ok, _ = pcall(function()
		return HttpService:RequestAsync({
			Url = webhookURL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(payload),
		})
	end)

	return ok == true
end
