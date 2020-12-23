import scala.language.postfixOps

object Day23 {

    /**
      * simulate a step
      * @param nums the data array. nums[0] will always represent the "front"
      */
    def update(nums: Array[Int]) {
        var curr = nums(0)
        var g1 = nums(curr)
        var g2 = nums(g1)
        var g3 = nums(g2)
        def prev(x: Int) = (if (x > 1) x else nums.size) - 1
        def find(x: Int) : Int = if (x == g1 || x == g2 || x == g3) find(prev(x)) else x
        var value = find(prev(curr))
        // advance to new curr
        nums(0) = nums(g3)
        nums(curr) = nums(g3)
        // splice [g1, g2, g3] after insertion point
        nums(g3) = nums(value)
        nums(value) = g1
    }

    /**
      * converts a sequence of numbers to a lookup array
      *
      * @param nums
      * @return
      */
    def build(nums: Seq[Int]) : Array[Int] = {
        var arr = new Array[Int](nums.size + 1)
        arr(0) = nums(0)
        for ((i,n) <- nums.view.zip(nums.view.drop(1) ++ nums.view.take(1))) arr(i) = n
        return arr
    }

    def part1 (nums : Seq[Int]) : Int = {
        var n = build(nums)
        for( _ <- 1 to 100) update(n)
        var curr = n(1)
        var answer = 0
        while (curr != 1) {
            answer = 10 * answer + curr
            curr = n(curr)
        } 
        return answer
    }

    def part2 (nums : Seq[Int]) : Long = {
        var n = build(nums)
        for( _ <- 1 to 10000000) update(n)
        var p1 = n(1).toLong
        var p2 = n(n(1)).toLong
        return p1 * p2
    }

    def main(args: Array[String]) {
        var nums = scala.io.StdIn.readLine.toList.map(x => x - '0')
        println(part1(nums))
        println(part2(nums ++ (10 to 1000000 toList)))
   }
}
