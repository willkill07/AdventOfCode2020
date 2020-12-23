import * as fs from 'fs'
import * as process from 'process'

var blob : string = fs.readFileSync(process.argv[2], "utf8")

let [p1, p2] = blob.split("\n\n").map(x => x.split("\n").splice(1).map(x => Number(x)))

const part1 = (p1 : number[], p2 : number[]) => {
  while (true) {
    if (p1.length === 0) return p2;
    if (p2.length === 0) return p1;
    const [[t1, ...r1], [t2, ...r2]] = [p1, p2];
    if (t1 > t2) {
      [t1, t2].forEach(x => r1.push(x))
    } else {
      [t2, t1].forEach(x => r2.push(x))
    }
    [p1, p2] = [r1, r2]
  }
}

const combat = (p1: number[], p2: number[]) : [number, number[]] => {
  const seen = new Set<string>();
  while (true) {
    if (p1.length === 0) return [2, p2];
    if (p2.length === 0) return [1, p1];
    const key = [p1, p2].map(x => x.join(',')).join('|');
    if (seen.has(key)) {
      return [1, p1];
    }
    seen.add(key);
    const [t1, t2] = [p1.shift(), p2.shift()]
    let win : number = t1 > t2 ? 1 : 2;
    if (p1.length >= t1 && p2.length >= t2) {
      [win, ] = combat(p1.slice(0, t1), p2.slice(0, t2));
    }
    if (win === 1) {
      [t1, t2].forEach(x => p1.push(x))
    } else {
      [t2, t1].forEach(x => p2.push(x))
    }
  }
}

const part2 = (p1: number[], p2: number[]) : number[] => combat(p1, p2)[1]

const calculate = (deck: number[]) => deck.reduce((acc: number, x: number, i: number) => acc + (deck.length - i) * x, 0)

console.log(calculate(part1(p1, p2)))
console.log(calculate(part2(p1, p2)))
