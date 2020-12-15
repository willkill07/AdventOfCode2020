<?php
  // You know we are in for a wild ride when we give PHP full system resources!
  ini_set('memory_limit', '-1');
  $input = array_map('intval', explode(",", file_get_contents($argv[1])));
  // I wanted to use zero-based indexing but ran into issues.
  // array_merge with a dummy value was way easier
  $nums = array_flip(array_merge(['$'], $input));
  $turn = $n = null;
  $i = count($nums);
  $update = function($i) {
    // stupid closure visibility
    global $nums, $n, $turn;
    $n = empty($turn) ? 0 : $i - 1 - $turn;
    // I learned about null coalescing when making sure ternaries existed
    $turn = $nums[$n] ?? null; 
    $nums[$n] = $i;
  };
  while ($i <= 2020) {
    $update($i++);
  }
  echo $n . PHP_EOL;
  while ($i <= 30000000) {
    $update($i++);
  }
  echo $n . PHP_EOL;
?>