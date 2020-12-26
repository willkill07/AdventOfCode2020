var fs = require('fs');

var blob = fs.readFileSync(process.argv[2], "utf8")

const transpose = mat => mat[0].map((_, i) => mat.map(row => row[i]))
const flip = mat => mat.map((row => row.map((e, i) => row[(row.length - 1) - i])))
const rotate = mat => flip(transpose(mat))

const transform = [
  m => m,
  m => rotate(m),
  m => rotate(rotate(m)),
  m => rotate(rotate(rotate(m))),
  m => flip(m),
  m => flip(rotate(m)),
  m => flip(rotate(rotate(m))),
  m => flip(rotate(rotate(rotate(m))))
]

const edge = {
  'top': x => x[0].join(''),
  'bottom': x => x[x.length - 1].join(''),
  'left': x => x.map(y => y[0]).join(''),
  'right': x => x.map(y => y[y.length - 1]).join('')
};

const edges_of = m => transform.map(fn => fn(m)[0].join(""))

// construct blocks
let blocks = (() => {
  let blocks = new Map();
  blob.split("\n\n").forEach(tile => {
    const [id, ...rest] = tile.split('\n')
    const num = +(id.split(' ')[1].slice(0, -1))
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

const dim_y = 12
const dim_x = 12
const size_y = corner_pieces[0].length
const size_x = corner_pieces[0][0].length

const placement = (() => {
  let seen = new Set();
  let places = Array.from(Array(12), () => new Array(12))

  const update = (j, i, pile, filtered) => {
    let [n, _] = (j === 0 && i === 0) ? [...corner_pieces][0] : neighbor_of(pile, filtered, seen) 
    places[j][i] = n;
    seen.add(n);
  };

  const next_to = (grid, j, i) => {
    list = []
    if (i > 0) list.push(grid[j][i - 1])
    if (j > 0) list.push(grid[j - 1][i])
    return list
  };

  const selector = (j, i) => {
    if ([0, dim_y - 1].includes(i) && [0, dim_y - 1].includes(j)) { return corner_pieces; }
    if ([0, dim_x - 1].includes(i) || [0, dim_x - 1].includes(j)) { return edge_pieces; }
    return neighbors;
  };

  // place the pieces in the correct location
  [...Array(dim_y).keys()].forEach(j =>
    [...Array(dim_x).keys()].forEach(i =>
      update(j, i, selector(j, i), next_to(places, j, i))));

  
  const _align_to = (self_id, constraints, first) => {
    const cs = first
      ? constraints.map(([piece, side]) => m => edges_of(blocks.get(piece)).includes(side(m)))
      : constraints.map(([piece, side, my_side]) => m => side(blocks.get(piece)) === my_side(m))
    const self = blocks.get(self_id)
    transform.some(fn => {
      const transform = fn(self)
      if (cs.every(pred => pred(transform))) {
        blocks.set(self_id, transform);
        return true;
      }
      return false;
    });
  };

  const align = (j, i) => {
    if (i === 0) {
      if (j === 0) { // corner -- orient piece to align with bottom and right
        _align_to(places[j][0], [[places[j + 1][0], edge.bottom], [places[0][1], edge.right]], true)
      } else { // left side -- match top <-> bottom
        _align_to(places[j][0], [[places[j - 1][0], edge.bottom, edge.top]]);
      }
    } else { // everything else -- match left <-> right
      _align_to(places[j][i], [[places[j][i - 1], edge.right, edge.left]]);
    }
  };

  // align the pieces with the neighboring pieces, start from upper-left
  [...Array(dim_y).keys()].forEach(j =>
    [...Array(dim_x).keys()].forEach(i =>
      align(j, i)));

  return places
})()

// assemble
const map =
  [...Array(dim_y).keys()].map(j =>
    [...Array(size_y).keys()].splice(1, size_y - 2).map(jj =>
      [...Array(dim_x).keys()].map(i =>
        [...Array(size_x).keys()].splice(1, size_x - 2).map(ii =>
          blocks.get(placement[j][i])[jj][ii])
        .join(''))
      .join(''))
    .join('\n'))
  .join('\n');
