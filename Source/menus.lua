local menus = {}


function menus.DrawMainMenu()

	local intSlabWidth = 700   -- the width of the main menu slab. Change this to change appearance.
    local intSlabHeight = 350   -- the height of the main menu slab
	local fltSlabWindowX = love.graphics.getWidth() / 2 - intSlabWidth / 2
	local fltSlabWindowY = love.graphics.getHeight() / 2 - intSlabHeight / 2

	-- try to centre the Slab window
	-- note: Border is the border between the window and the layout
	local mainMenuOptions = {
		Title = "Main menu " .. GAME_VERSION,
		X = fltSlabWindowX,
		Y = fltSlabWindowY,
		W = intSlabWidth,
		H = intSlabHeight,
		Border = 20,
		AutoSizeWindow=false,
		AllowMove=false,
		AllowResize=false,
		NoSavedSettings=true
	}

	local columnwidth = 150
	local buttonheight = 50

	Slab.BeginWindow('MainMenu', mainMenuOptions)
		Slab.BeginLayout("MMLayout",{AlignX="center",AlignY="top",AlignRowY="center",ExpandW=false,Columns = 3})

	        Slab.SetLayoutColumn(1)
				Slab.NewLine()
				Slab.NewLine()
				Slab.NewLine()
				Slab.NewLine()
	            Slab.Image('MyImage', {Image = image[enum.mainmenu], Scale=0.40})

	        Slab.SetLayoutColumn(2)
				Slab.NewLine()
	            if Slab.Button("New game",{W=columnwidth, H = buttonheight}) then
					cf.AddScreen("GameLoop", SCREEN_STACK)
	     		end

				Slab.NewLine()
	            if Slab.Button("Continue game",{W=columnwidth, H = buttonheight}) then
	     		end

				Slab.NewLine()
	            if Slab.Button("Save game",{W=columnwidth, H = buttonheight}) then
	     		end

				Slab.NewLine()
				if Slab.Button("Exit", {W=columnwidth, H = buttonheight}) then
					love.event.quit()
			    end

	        Slab.SetLayoutColumn(3)
				Slab.NewLine()
	            if Slab.Button("Multiplayer",{W=columnwidth, H = buttonheight}) then
	     		end

				Slab.NewLine()
	            if Slab.Button("Settings",{W=columnwidth, H = buttonheight}) then
	     		end

				Slab.NewLine()
	            if Slab.Button("Credits",{W=columnwidth, H = buttonheight}) then
					cf.AddScreen("Credits", SCREEN_STACK)
	     		end
	    Slab.EndLayout()

	Slab.EndWindow()
end

function menus.DrawCredits()

	local intSlabWidth = 550	-- the width of the main menu slab. Change this to change appearance.
	local intSlabHeight = 500 	-- the height of the main menu slab
	local fltSlabWindowX = love.graphics.getWidth() / 2 - intSlabWidth / 2
	local fltSlabWindowY = love.graphics.getHeight() / 2 - intSlabHeight / 2

	local creditBoxOptions = {
		Title ='About',
		BgColor = {0.4, 0.4, 0.4},
		AutoSizeWindow=false,
		AllowMove=false,
		AllowResize=false,
		NoSavedSettings=true,
		X = fltSlabWindowX,
		Y = fltSlabWindowY,
		W = intSlabWidth,
		H = intSlabHeight
	}

	local URLOptions = function(url)
		local option = {}
		option.URL = url
		option.IsSelectable = true
		option.IsSelectableTextOnly = true
		option.HoverColor = {0.75, 0.75, 0.75}
		return option
	end

	Slab.BeginWindow('creditsbox', creditBoxOptions)
	Slab.BeginLayout('credits', {AlignX = 'center'})

		Slab.BeginLayout('credits-top', {AlignX = 'center'})
			Slab.Text("General Quarters")
			Slab.Text("Github Repository", URLOptions("https://github.com/togfoxy/GeneralQuarters"))
			Slab.Text("A Love2D community project")
			Slab.Separator()
		Slab.EndLayout()

		Slab.BeginLayout('credits-middle', {AlignX = 'center', AlignY = 'top', AlignRowY='center', Columns = 2})

		Slab.SetLayoutColumn(1)
			Slab.Text("Contributors:")
			Slab.NewLine()
			Slab.Text("TOGFox")
			-- Slab.Text("Milon")
			-- Slab.Text("Gunroar:Cannon()")
			-- Slab.Text("Philbywhizz")
			-- Slab.Text("MadByte")
			Slab.NewLine()

			Slab.Text("Thanks to beta testers:",{Align = 'center'})
			Slab.NewLine()
			-- Slab.Textf("Boatman",{Align = 'right'})
			-- Slab.Textf("Darth Carcas",{Align = 'right'})
			-- Slab.Textf("Mini Yum",{Align = 'right'})
			Slab.NewLine()

		Slab.SetLayoutColumn(2)
			Slab.Text("Acknowledgements:")
			Slab.NewLine()
			Slab.Text("Love2D", URLOptions("https://love2d.org"))
			Slab.Text("SLAB for Love2D", URLOptions("https://github.com/coding-jackalope/Slab"))
			-- Slab.Text("aspect", URLOptions("https://love2d.org/forums/viewtopic.php?f=5&p=245515#p245515"))
			Slab.Text("inspect", URLOptions("https://github.com/kikito/inspect.lua"))
			Slab.Text("freesound.org", URLOptions("https://freesound.org/"))
			Slab.Text("bitser", URLOptions("https://github.com/gvx/bitser"))
			Slab.Text("nativefs", URLOptions("https://github.com/megagrump/nativefs"))
			Slab.Text("anim8", URLOptions("https://github.com/kikito/anim8"))
			Slab.Text("Lovely-Toasts", URLOptions("https://github.com/Loucee/Lovely-Toasts"))
			Slab.Text("sock", URLOptions("https://github.com/camchenry/Sock.lua"))
			-- Slab.Text("Paddy") -- , URLOptions("https://github.com/camchenry/Sock.lua"))

			-- Slab.Text("Galactic Pole Position by Eric Matyas. ", URLOptions("www.soundimage.org"))

			--Slab.Text("Dark Fantasy Studio", URLOptions("http://darkfantasystudio.com/"))

			Slab.EndLayout()


		Slab.BeginLayout('credits-bottom', {AlignX = 'center', AlignY = 'top'})
			Slab.Separator()
			Slab.NewLine()
			Slab.Text("Thanks to the Love2D community")
			Slab.NewLine()
			Slab.Text("All material generated by the team, used with ",{Align = 'center'})
			Slab.Text("permission, or under creative commons",{Align = 'center'})
			Slab.NewLine()

			if Slab.Button("Awesome!") then
				-- return to the previous game state
				cf.RemoveScreen(SCREEN_STACK)
			end

		Slab.EndLayout()

	Slab.EndLayout()
	Slab.EndWindow()
end

return menus
