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

const edges_of = m => transform.map(fn => fn(m)[0].join(''))

// construct
let pieces = (() => {
  let pieces = new Map();
  blob.split('\n\n').forEach(tile => {
    const [id, ...rest] = tile.split('\n')
    const num = +(id.split(' ')[1].slice(0, -1))
    pieces.set(num, rest.map(x => [...x]))
  })
  return pieces
})()

const neighbor_map = (() => {
  let uids = new Map();
  pieces.forEach((mat, id) =>
    edges_of(mat).forEach(row =>
      uids.set(row, (uids.has(row) ? uids.get(row) : new Set()).add(id))))
  let map = new Map();
  [...uids].forEach(([_, connected]) => connected.forEach(x => {
    let set = map.has(x) ? map.get(x) : new Set();
    [...connected].filter(y => y != x).forEach(y => set.add(y));
    map.set(x, set);
  }))
  return map
})();

const pieces_with_count = n => new Map([...neighbor_map].filter(([_, set]) => set.size === n))

const corner_pieces = pieces_with_count(2)
const edge_pieces = pieces_with_count(3)

const product = [...corner_pieces].reduce((a,x) => a * x[0], 1)

// Part 1
console.log(product)

const [dim_y, dim_x, size_y, size_x] = [12, 12, 10, 10]

function* range(lo, hi) {
  while (lo < hi) {
    yield lo++
  }
}

const placement = (() => {
  let seen = new Set();
  let places = Array.from(Array(dim_y), () => new Array(dim_x));

  const update = (j, i) => {
    const selector = (j, i) => {
      if ([0, dim_y - 1].includes(i) && [0, dim_y - 1].includes(j)) { return corner_pieces; }
      if ([0, dim_x - 1].includes(i) || [0, dim_x - 1].includes(j)) { return edge_pieces; }
      return neighbor_map;
    };
    const next_to = (j, i) => Array.of(i > 0 ? places[j][i - 1] : null, j > 0 ? places[j - 1][i] : null).filter(x => x);

    const pile = selector(j, i)
    const filtered = next_to(j, i)
    const neighbor_of = (pieces, req, seen) => [...pieces].filter(([id, adj]) => !seen.has(id) && req.every(v => adj.has(v)))[0]
    let [n, _] = (j === 0 && i === 0) ? [...corner_pieces][0] : neighbor_of(pile, filtered, seen) 
    places[j][i] = n;
    seen.add(n);
  };

  const align = (j, i) => {
    const _align_to = (self_id, constraints, first) => {
      const cs = first
        ? constraints.map(([piece, side]) => m => edges_of(pieces.get(piece)).includes(side(m)))
        : constraints.map(([piece, side, my_side]) => m => side(pieces.get(piece)) === my_side(m))
      const self = pieces.get(self_id)
      transform.some(fn => (cs.every(pred => pred(fn(self)))) && (pieces === pieces.set(self_id, fn(self))));
    };
    return (i === 0) ?
        ((j === 0) ?
        _align_to(places[j][0], [[places[j + 1][0], edge.bottom], [places[0][1], edge.right]], true) :
        _align_to(places[j][0], [[places[j - 1][0], edge.bottom, edge.top]])) :
      _align_to(places[j][i], [[places[j][i - 1], edge.right, edge.left]]);
  }

  // place the pieces in the correct location
  [...range(0, dim_y)].forEach(j =>
    [...range(0, dim_x)].forEach(i =>
      update(j, i)));

  // align the pieces with the neighboring pieces, start from upper-left
  [...range(0, dim_y)].forEach(j =>
    [...range(0, dim_x)].forEach(i =>
      align(j, i)));

  return places
})()

// Assemble the entire puzzle
const assembled_puzzle =
  [...range(0, dim_y)].map(j =>
    [...range(1, size_y - 1)].map(jj =>
      [...range(0, dim_x)].map(i =>
        [...range(1, size_x - 1)].map(ii =>
          pieces.get(placement[j][i])[jj][ii])
        .join(''))
      .join(''))
    )
  .flat().map(x => x.split(''))

// component for identifing the monster
const monster =
`                  #
#    ##    ##    ###
 #  #  #  #  #  #   `
  .split('\n')
  .map((row, j) => row.split('').map((cell, i) => [j, i, cell]).filter(a => a[2] === '#'))
  .flat()

const monster_height = monster.reduce((max, [j, ]) => (j > max ? j : max), 0) + 1
const monster_width = monster.reduce((max, [_, i, ]) => (i > max ? i : max), 0) + 1

const [EMPTY, MARKED, UNMARKED] = ['.', '^', '#']

const mark = (map) => {
  const map_height = map.length;
  const map_width = map[0].length;
  [...range(0, map_height - monster_height)].forEach(bj =>
    [...range(0, map_width - monster_width)].forEach(bi => {
      // when all the monster elements are found, mark all of them
      if (monster.every(([j, i, ]) => map[bj + j][bi + i] !== EMPTY)) {
        monster.forEach(([j, i, ]) => map[bj + j][bi + i] = MARKED)
      }
    }));
  return map;
}

const count =
  // transformations
  [0, 1, 2, 3, 4, 5, 6, 7] 
  // mark all monsters
  .reduce((m, i) => (i === 3) ? flip(rotate(mark(m))) : rotate(mark(m)), assembled_puzzle)
  // 2-D reduction on counting unmarked seabed
  .reduce((c, row) => c + row.reduce((rc, cell) => rc + +(cell === UNMARKED), 0), 0);

// Part 2
console.log(count);
