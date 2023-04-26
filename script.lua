
print("Hello from lua!")

-- global function defined in C
hello_world()

-- Function defined in lua, used in C
function concat(a, b)
    return a .. b
end
