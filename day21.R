library(purrr)

# parse input 
data <- strsplit(readLines(), "\\(contains ")
allergens <- lapply(data, pluck, 2)
allergens <- lapply(allergens, gsub, pattern = "\\)", replacement = "")
allergens <- lapply(allergens, function(x) strsplit(x, ", ")[[1]])
ingredients <- lapply(data, pluck, 1)
ingredients <- lapply(ingredients, function(x) strsplit(x, " ")[[1]])
all_ingredients <- unique(unlist(ingredients))

recipe <- new.env()

# part 1

for (i in seq_along(ingredients)) {
    all <- allergens[[i]]
    ing <- ingredients[[i]]
    for (a in all){
        recipe[[a]] <- if (!exists(a, envir = recipe)) ing else intersect(recipe[[a]], ing)
    }
}
allergens <- as.list(recipe)
contain_allergen <- unname(unlist(allergens))
no_allergen <- setdiff(all_ingredients, contain_allergen)
part1answer <- sum(table(unlist(ingredients))[no_allergen])

# Part 2
result <- rep(NA, length(allergens))
names(result) <- names(allergens)
repeat {
    l <- lapply(allergens, length)
    if (any(l > 0)) {
        break
    }
    x <- which(l == 1)[1]
    p <- allergens[[x]]
    result[names(x)] <- p
    allergens <- lapply(allergens[-x], setdiff, p)
}

part2answer <- paste(result[order(names(result))], collapse = ",")

cat(part1answer)
cat(part2answer)
