local Neuron = require("neuron")
local Brain = {}

function printNodes(nodes)
    for k,_ in pairs(nodes) do
        local node = nodes[k]
        str = str .. node:string()
        str = str .. "----------------------------------------\n"
    end
end

function repairConnections(brain, nodes)
    for k, node in pairs(nodes) do
        if #node.weights == 0 then
            local i = math.random(1, #brain.inputNodes)
            brain.inputNodes[i]:connect(node, math.random() * 20 - 10)
            table.insert(brain.connections, i .. " -> " .. k .. " (repaired)")
        end
    end
end

function detectLoop(a, b)
    
    for _,n in pairs(a.outputs) do
        print(a, n, b)

        if n == b then 
            return true
        elseif detectLoop(n, b) == true then
            return true
        end
    end

    return false
end


Brain.new = function(dna)
    local brain = {}

    brain.inputNodes  = {}
    brain.hiddenNodes = {}
    brain.outputNodes = {}

    brain.connections = {}

    -- Create the brain's nodes
    for i = 1, #dna.nodeGenes do
        local gene = dna.nodeGenes[i]

        if gene.kind == "input" then
            brain.inputNodes[gene.num] = Neuron.new(gene.bias, Neuron.activationFunctions[gene.func])
        elseif gene.kind == "hidden" then
            brain.hiddenNodes[gene.num] = Neuron.new(gene.bias, Neuron.activationFunctions[gene.func])
        else
            brain.outputNodes[gene.num] = Neuron.new(gene.bias, Neuron.activationFunctions[gene.func])
        end
    end

    -- Create the brain's connections
    for i = 1, #dna.connectionGenes do
        local gene   = dna.connectionGenes[i]
        local input  = brain.inputNodes[gene.inp] or brain.hiddenNodes[gene.inp]
        local output = brain.hiddenNodes[gene.out] or brain.outputNodes[gene.out]


        if input ~= nil and output ~= nil and input ~= output then
            local valid = not detectLoop(input, output)

            for i = 1, #brain.connections do
                if gene.inp .. " -> " .. gene.out == brain.connections[i] then
                    valid = false
                end
            end

            if valid then
                input:connect(output, gene.weight)
                table.insert(brain.connections, gene.inp .. " -> " .. gene.out)
            end
        end
    end

    -- To avoid "hanging" nodes, any node which lacks a connection will
    -- get connected something with a random weight
    repairConnections(brain, brain.hiddenNodes)
    repairConnections(brain, brain.outputNodes)

    brain.process = function(self, input)
        -- step 0: we transform the input so it can fit into the input
        -- layer of the brain
        if type(input) == 'number' then
            input = {input}
        end

        local keys = {}
        for k,_ in ipairs(self.inputNodes) do
            table.insert(keys, k)
        end

        local t_input = {}
        for i = 1, math.min(#input, #keys) do
            t_input[keys[i]] = input[i]
        end

        -- step 1: we feed the input to the brain and process it
        -- inputs are always in first order so we can use ipairs
        for k, node in ipairs(self.inputNodes) do
            table.insert(node.inputs, input[k])
            node:process()
        end

        -- step 2: we process the input in hidden nodes that can be processed
        local keys = {}
        for k in pairs(self.hiddenNodes) do
            table.insert(keys, k)
        end

        table.sort(keys, function(a, b) return a > b end)

        while #keys > 0 do
            for i = #keys, 1, -1 do
                local node = self.hiddenNodes[keys[i]]

                if #node.weights == #node.inputs then
                    node:process()
                    table.remove(keys, i)
                end
            end
        end

        -- step 3: we now should be able to get the output of the brain
        local result = {}
        local keys = {}
        for k in pairs(self.outputNodes) do
            table.insert(keys, k)
        end

        table.sort(keys)

        for i, k in ipairs(keys) do
            table.insert(result, self.outputNodes[k]:process())
        end

        return result
    end

    brain.string = function(self)
        str = "BRAIN:\nNodes:\n------\n"
        
        str = str .. "Input Nodes\n"
        printNodes(self.inputNodes)

        str = str .. "Hidden Nodes\n"
        printNodes(self.hiddenNodes)

        str = str .. "Output Nodes\n"
        printNodes(self.outputNodes)

        str = str .. "\nConnections:\n------------\n"

        for i = 1, #self.connections do
            conn = self.connections[i]
            str = str .. "+   " .. conn .. "\n"
        end
        
        str = str .. "----------------------------------------\n"

        return str
    end

    return brain
end

return Brain