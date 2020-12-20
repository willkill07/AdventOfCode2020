import java.io.File
import kotlin.system.exitProcess

open class Rule
class Terminal(var char: Char) : Rule()
class Choice(var choices: List<List<Int>>) : Rule()

fun buildRules(str: String): Pair<Int, Rule> {
  var (num, prod) = str.split(':').map(String::trim)
  if (prod.startsWith('"')) {
    return num.toInt() to Terminal(prod[1])
  }
  var choices = prod.trim()
    .split('|')
    .map(String::trim)
    .map { it.split(' ').map(String::toInt) }
  return num.toInt() to Choice(choices)
}

fun parse(rules: Map<Int, Rule>, sentence: String, pda: List<Int>): Boolean {
  if (pda.isEmpty()) {
    return sentence.isEmpty()
  }
  var rule = rules[pda.first()]!!
  return when (rule) {
    is Terminal -> sentence.startsWith(rule.char) && parse(rules, sentence.drop(1), pda.drop(1))
    is Choice -> rule.choices.firstOrNull { choice -> parse(rules, sentence, choice + pda.drop(1)) } != null
    else -> false
  }
}

var (rulesString, dataString) = File(args[0]).readText().split("\n\n")

var rules = rulesString.split('\n')
  .map(::buildRules)
  .toMap().toSortedMap()

// part 1
dataString.split("\n")
  .count { str -> parse(rules, str, listOf(0)) }
  .apply(::println)

// part 2
rules.replace(8, Choice(listOf(listOf(42), listOf(42, 8))))
rules.replace(11, Choice(listOf(listOf(42, 31), listOf(42, 11, 31))))
dataString.split("\n")
  .count { str -> parse(rules, str, listOf(0)) }
  .apply(::println)

exitProcess(0)
