var fs = require('fs');

var blob = fs.readFileSync(process.argv[2], "utf8")

const transpose = mat => mat[0].map((_, i) => mat.map(row => row[i]))
const flip = mat => mat.map((row => row.map((e, i) => row[(row.length - 1) - i])))
const rotate = mat => flip(transpose(mat))

const edges_of = mat => {
  const r90 = rotate(mat)
  const r180 = rotate(r90)
  const r270 = rotate(r180)
  const flipped = flip(mat)
  const f90 = rotate(flipped)
  const f180 = rotate(f90)
  const f270 = rotate(f180)
  return [mat, r90, r180, r270, flipped, f90, f180, f270].map(x => x[0].join())
};

// construct blocks
let blocks = (() => {
  let blocks = new Map();
  blob.split("\n\n").forEach(tile => {
    const [id, ...rest] = tile.split('\n')
    const num = Number(id.split(' ')[1].slice(0, -1))
    blocks.set(num, rest.map(x => [...x]))
  })
  return blocks
})()

const unique_ids = (() => {
  let uids = new Map();
  blocks.forEach((mat, id) =>
    edges_of(mat).forEach(row =>
      uids.set(row, (uids.has(row) ? uids.get(row) : new Set()).add(id))))
  return uids
})()

const neighbors = (() => {
  let neighbors = new Map();
  [...unique_ids].forEach(([_, connected]) => connected.forEach(x => {
    let set = neighbors.has(x) ? neighbors.get(x) : new Set();
    [...connected].filter(y => y != x).forEach(y => set.add(y));
    neighbors.set(x, set);
  }))
  return neighbors
})();

const pieces_with_count = n => new Map([...neighbors].filter(([_, set]) => set.size === n))

const corner_pieces = pieces_with_count(2)
const edge_pieces = pieces_with_count(3)

const neighbor_of = (pieces, req, seen) => [...pieces].filter(([id, adj]) => !seen.has(id) && req.every(v => adj.has(v)))[0]

const product = [...corner_pieces].reduce((a,x) => a * x[0], 1)
// Part 1
console.log(product)

const placement = (() => {
  let seen = new Set();
  let places = Array.from(Array(12), () => new Array(12))
  let [j, i] = [0, 0]

  // grab a corner
  let [next, _] = [...corner_pieces][0]
  places[j][i++] = next;
  seen.add(next);

  const update = (j, i, pile, filtered) => {
    let [next, _] = neighbor_of(pile, filtered, seen)
    places[j][i] = next;
    seen.add(next);
    if (++i == 12) {
      ++j
    }
    return [j, i]
  };

  function next_to(grid, j, i) {
    list = []
    if (i > 0) list.push(grid[j][i - 1])
    if (j > 0) list.push(grid[j - 1][i])
    return list
  }

  // fill the top
  while (i < 11) {
    [j, i] = update(j, i, edge_pieces, next_to(places, j, i))
  }
  [j, i] = update(j, i, corner_pieces, next_to(places, j, i))

  // process row-by-row from left-to-right
  while (j < 12) {
    [j, i] = update(j, 0, neighbors, next_to(places, j, 0))
    while(i < 12) {
      [j, i] = update(j, i, neighbors, next_to(places, j, i))
    }
  }
  return places
})()

const mine = edges_of(blocks.get(placement[0][0]))
const mine_u = mine.map((val, idx) => [val, idx])

const below = edges_of(blocks.get(placement[1][0]))
  .map((val, idx) => [val, idx])
  .filter(([v,_]) => unique_ids.get(v).size === 1)

const right = edges_of(blocks.get(placement[0][1]))
  .map((val, idx) => [val, idx])
  .filter(([v,_]) => unique_ids.get(v).size === 1)
