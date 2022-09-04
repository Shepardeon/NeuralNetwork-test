DNA   = require("dna")
Brain = require("brain")
Neurone = require("neuron")

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
    local dna = DNA.new()

    dna:addNode("input", 0, "linear")
    dna:addNode("input", 0, "linear")
    dna:addNode("output", 0, "linear")
    dna:addNode("hidden", 0, "linear")
    dna:addNode("hidden", 0, "linear")
    

    dna:addConnection(1, 4, 1)
    dna:addConnection(1, 3, 2)
    dna:addConnection(2, 4, 2)
    dna:addConnection(4, 3, 1)
    dna:addConnection(5, 3, 1)

    --print(dna:string())

    local brain = Brain.new(dna)

    print(brain:process({3, 4})[1])
    --print(brain:string())
end


function love.update(dt)

end

function love.draw()
    
end
local a = {true, false}
function love.keypressed(key)
    if key == "space" then
        --[[local nDna = DNA.new()

        nDna:addNode("input", 0, "linear")
        nDna:addNode("input", 0, "linear")
        nDna:addNode("input", 0, "linear")
        nDna:addNode("output", 0, "step")
        nDna:addNode("output", 0, "step")
        nDna:addNode("output", 0, "step")


        nDna:generate(3, 3)

        local nBrain = Brain.new(nDna)

        print(nBrain:string())
        print("\n")

        print(unpack(nBrain:process({250, 0, 12})))]]

        a = Neurone.new(1, Neurone.activationFunctions.linear)
        b = Neurone.new(2, Neurone.activationFunctions.linear)
        c = Neurone.new(3, Neurone.activationFunctions.linear)
        d = Neurone.new(4, Neurone.activationFunctions.linear)
        e = Neurone.new(5, Neurone.activationFunctions.linear)
        f = Neurone.new(6, Neurone.activationFunctions.linear)

        a:connect(c)
        c:connect(f)
        c:connect(d)
        d:connect(e)
        b:connect(e)

        print(detectLoop(a, b))
    end
end