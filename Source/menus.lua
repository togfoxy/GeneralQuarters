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
	     		end
	    Slab.EndLayout()

	Slab.EndWindow()
end





return menus
