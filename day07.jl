rules = open(ARGS[1]) do file
  Dict([match(r"(\w+ \w+) bags contain", l).captures[1] => Dict([m.captures[2] => parse(Int, m.captures[1]) for m in eachmatch(r"(\d+) (\w+ \w+)", l)]) for l in eachline(file)])
end

key = "shiny gold"

function add!(all_bags, bag)
  for (c, elems) in rules
    if !in(all_bags, c) && haskey(elems, bag)
      push!(all_bags, c)
      add!(all_bags, c)
    end
  end
  all_bags
end

p1 = length(add!(Set(), key))
println("$p1")

function contains(bag, cost)::Int
  cost * (1 + sum([contains(c, num) for (c, num) in rules[bag]]))
end

p2 = contains(key, 1) - 1
println("$p2")