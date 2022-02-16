local armybravo = {}



function armybravo.Initialise()

    newflotilla = fun.createNewFlotilla("Bravo")
    newflotilla.formation = {}

    newformation = fun.createNewFormation()
    table.insert(newflotilla.formation, newformation)

    newformation.marker = {}
    -- addFriedrichDerGrosse(1, 1)
    -- addGrosserKerflirst(1, 1)
    for i = 1, love.math.random(3, 15) do
        fun.addGenericMarker(2, 1)
    end

    newformation.marker[1].isFlagship = true

end


return armybravo
