-- Use up some random numbers
math.randomseed(os.time())
math.random(); math.random(); math.random()

local DNA = {}

local MAX_HIDDEN = 10

-- Chance to have a spontaneous change
local MUTATION_RATE = 0.05

-- Chance, when there is a mutation to have one of
-- those changes

-- 30% chance of structural change (new node / connection)
-- in 70% of other cases, it will be a change of weight or bias
local STRUCTURE_CHANGE_RATE = 0.3

-- 40% chance of getting a new node in case of a structural change
-- 60% chance of getting a new connection otherwise
local NEW_NODE_RATE = 0.4

local POSSIBLE_FUNCTIONS = { "step", "signum", "linear", "pwlinear", "sigmoid", "hypertan", "relu", "softplus" }


-- For simplicity sakes, we'll keep weights and biases between -10 and 10

DNA.new = function()

    local dna = {}

    dna.nodeGenes = {}
    dna.connectionGenes = {}

    dna.addNode = function(self, kind, bias, func)
        table.insert(self.nodeGenes, {num = #dna.nodeGenes + 1, kind = kind, bias = bias, func = func})
    end

    dna.addConnection = function(self, inp, out, weight)
        table.insert(self.connectionGenes, {inp = inp, out = out, weight = weight})
    end

    dna.newNode = function(self)
        -- The algorithm can only create new hidden nodes as input and output nodes
        -- depends on the structure imposed by the user
        table.insert(self.nodeGenes, {
            num = #self.nodeGenes + 1, 
            kind = "hidden", 
            bias = math.random() * 20 - 10,
            func = POSSIBLE_FUNCTIONS[math.random(1, #POSSIBLE_FUNCTIONS)]
        })

        -- We also need to create new connections for this new node otherwise
        -- it will be useless, we will create it one random input and one random output
        self:newConnection(#self.nodeGenes, true)
        self:newConnection(#self.nodeGenes, false)
    end

    dna.newConnection = function(self, node, input)
        -- This code could create genetic information that does nothing
        -- but it can always be modified further down the line with mutations
        local tbl = {true, false}

        node  = node or math.random(1, #self.nodeGenes)
        input = input or tbl[math.random(1, 2)]

        if input then 
            table.insert(self.connectionGenes, {
                inp    = node,
                out    = math.random(1, #self.nodeGenes),
                weight = math.random() * 20 - 10
            })
        else
            table.insert(self.connectionGenes, {
                inp    = math.random(1, #self.nodeGenes),
                out    = node,
                weight = math.random() * 20 - 10
            })
        end
    end

    dna.generate = function(self, nInput, nOutput, maxHidden)
        maxHidden = maxHidden or MAX_HIDDEN


        if #self.nodeGenes == 0 then

            for i = 1, nInput do
                self:addNode("input", math.random() * 20 - 10, "sigmoid")
            end

            for i = 1, nOutput do
                self:addNode("output", math.random() * 20 - 10, "relu")
            end

        end

        local nHidden = math.random(0, maxHidden)
        local nConnec = math.random(nInput+nHidden, nInput+nHidden+nOutput)

        for i = 1, nHidden do
            self:newNode()
        end

        for i = #self.connectionGenes, nConnec do
            self:newConnection()
        end
    end

    dna.string = function(self)
        str = "DNA:\nNodes:\n------\n"
        
        for i = 1, #self.nodeGenes do
            for k, v in pairs(self.nodeGenes[i]) do
                str = str .. "+   " .. k .. ": " .. v .. "\n"
            end
            str = str .. "----------------------------------------\n"
        end

        str = str .. "\nConnections:\n------------\n"

        for i = 1, #self.connectionGenes do
            for k, v in pairs(self.connectionGenes[i]) do
                str = str .. "+   ".. k .. ": " .. v .. "\n"
            end
            str = str .. "----------------------------------------\n"
        end

        return str
    end

    return dna

end


return DNA