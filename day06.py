import functools
import sys

def input(filename):
  with open(filename) as f:
    for g in f.read().split('\n\n'):
      yield g.rstrip().split('\n')

def count(group):
  unique = set(q for l in group for q in l)
  return len(unique), len(set.intersection(unique, *(set(q for q in l) for l in group)))

def solve(filename):
  return functools.reduce(lambda a,b: (b[0]+a[0], b[1]+a[1]), (count(g) for g in input(filename)), (0,0))

p1, p2 = solve(sys.argv[1])
print (p1)
print (p2)
