local Neuron = {}

Neuron.activationFunctions = {

    step = function(x)
        if x < 0 then return 0
        else return 1 end
    end,

    signum = function(x)
        if x < 0 then return -1
        elseif x == 0 then return 0
        else return 1 end
    end,

    linear = function(x)
        return x
    end,

    pwlinear = function(x)
        if x <= -1/2 then return 0
        elseif x > -1/2 and x < 1/2 then return x + 1/2
        else return x end
    end,

    sigmoid = function(x)
        return 1 / (1 + math.exp(-x))
    end,

    hypertan = function(x)
        return (math.exp(x) - math.exp(-x)) / (math.exp(x) + math.exp(-x))
    end,

    relu = function(x)
        return math.max(0, x)
    end,

    softplus = function(x)
        return math.log(1 + math.exp(x))
    end

}

Neuron.new = function(bias, activationFunction)
    local neuron = {}

    neuron.inputs   = {}
    neuron.outputs  = {}
    neuron.weights  = {}
    neuron.bias     = bias or 0

    neuron.activationFunction = activationFunction or Neuron.activationFunctions.sigmoid

    neuron.process = function(self)
        -- We should compute our weighted sum and pass it to our
        -- activation function
        local sum = 0

        for i = 1, #self.inputs do
            sum = sum + self.inputs[i] * (self.weights[i] or 1)
        end

        local result = self.activationFunction(sum + self.bias)

        for i = 1, #self.outputs do
            table.insert(self.outputs[i].inputs, result)
        end

        return result
    end

    neuron.connect = function(self, other, weight)
        table.insert(self.outputs, other)
        table.insert(other.weights, weight)
    end

    neuron.string = function(self)
        local str = ""

        str = str .. "+   bias: " .. self.bias .. "\n"

        str = str .. "+   inputs:\n    -------\n"
        for k, v in pairs(self.inputs) do
            str = str .. "    +   " .. k .. ": " .. v .. "\n"
        end

        str = str .. "+   weights:\n    --------\n"
        for k, v in pairs(self.weights) do
            str = str .. "    +   " .. k .. ": " .. v .. "\n"
        end

        return str
    end

    return neuron
end

return Neuron