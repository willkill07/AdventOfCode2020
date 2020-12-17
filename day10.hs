import Data.List
import System.Environment

convert :: String -> [Int]
convert = map read . lines

absdiff :: [Int] -> [Int]
absdiff lst = zipWith (diff_num lst) [0 .. ] lst

diff_num :: [Int] -> Int -> Int -> Int
diff_num diff idx number
    | first = number
    | otherwise = number - diff !! (idx -1)
    where first = idx == 0

ordering :: [Int] -> Int
ordering lst = product filtered
    where filtered = map possibilities $ filter (1  `elem` ) $ group lst

possibilities :: [Int] -> Int
possibilities lst
    | l < 4 = 2 ^ (l - 1)
    | l == 4 = 7
    where l = length lst

main = do
    args <- getArgs
    content <- readFile (head $ args)
    let diffs = absdiff (sort $ convert content) ++ [3]
    let diff1 = length $ filter (== 1) diffs
    let diff3 = length $ filter (== 3) diffs
    print $ diff1 * diff3
    print $ ordering diffs
