use std::io::{self, BufRead};

fn part1(lines: &[String]) -> usize {
  let first: usize = lines[0].parse().unwrap();
  let (id, wait) = lines[1]
    .split(',')
    .filter(|freq| freq != &"x")
    .map(|id| id.parse::<usize>().unwrap())
    .map(|id| (id, id - (first % id)))
    .min_by_key(|pair| pair.1)
    .unwrap();
  id * wait
}

fn part2(lines: &[String]) -> u64 {
  let ids: Vec<u64> = lines[1].split(',').map(|s| s.parse::<u64>().unwrap_or(0)).collect();
  let mut answer: u64 = 0;
  let mut step: u64 = 1;
  for (offset, id) in ids.iter().enumerate() {
    if *id == 0 { continue} ;
    for timestamp in (answer..u64::MAX).step_by(step as usize) {
      if (timestamp + offset as u64) % id == 0 {
        answer = timestamp;
        step *= id;
        break;
      }
    }
  }
  answer
}

fn main() {
    let lines: Vec<String> = io::stdin().lock().lines().map(|x| x.unwrap()).collect();
    println!("{}", part1(&lines));
    println!("{}", part2(&lines));
}