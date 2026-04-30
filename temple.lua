if getcustomasset then
	local link = "https://raw.githubusercontent.com/2863862963872963/uis-vault/main/UiPics/assets/%s";
	local dir = 'AscHub/Images';

	if not isfolder(dir) then
		makefolder(dir);
	end;

	pcall(function()
		if not isfile(dir..'/'..'logo.png') then
			local byte = game:HttpGet(string.format(link,'logo.png'));

			writefile(dir..'/'..'logo.png' , byte);
			task.wait();
		end;
	end);

	pcall(function()
		if not isfile(dir..'/'..'logo2.png') then
			local byte = game:HttpGet(string.format(link,'logo2.png'));

			writefile(dir..'/'..'logo2.png' , byte);
			task.wait();
		end;
	end);

end;
