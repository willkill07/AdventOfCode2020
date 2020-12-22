#include <array>
#include <iostream>
#include <algorithm>
#include <unordered_set>
#include <utility>

template <std::size_t N>
using point = std::array<int, N>;

namespace std {
  template <std::size_t N>
  struct hash<point<N>> {
    constexpr std::size_t operator()(point<N> const& p) const noexcept {
      return [&] <std::size_t ... Is> (std::index_sequence<Is...>) {
        std::size_t h {23};
        (... , (h *= h*31 + p[Is]));
        return h;
      }(std::make_index_sequence<N>{});
    }
  };
}

template <std::size_t N, std::size_t I = 0>
void
_neighbors(point<N>& orig, std::unordered_set<point<N>>& ns) {
  if constexpr (I == N) {
    ns.insert(orig);
  } else {
    int loc = orig[I];
    for (int i : {-1, 0, 1}) {
      orig[I] = loc + i;
      _neighbors<N, I + 1>(orig, ns);
    }
    orig[I] = loc;
  }
}

template <std::size_t N>
std::unordered_set<point<N>>
get_neighbors(point<N> const& orig) {
  point<N> p {orig};
  std::unordered_set<point<N>> adj;
  _neighbors(p, adj);
  adj.erase(orig);
  return adj;
}

template <std::size_t N>
std::unordered_set<point<N>>
step(std::unordered_set<point<N>> const& locs) {
  std::unordered_set<point<N>> candidates;
  for (auto& l : locs) {
    for (auto& n : get_neighbors(l)) {
      candidates.insert(std::move(n));
    }
  }
  std::unordered_set<point<N>> next_locs;
  for (auto const & c : candidates) {
    auto count = std::ranges::count_if(
      get_neighbors(c),
      [&] (point<N> const& n) {
        return locs.contains(n);
      });
    if ((count == 3) || (locs.contains(c) && count == 2)) {
      next_locs.insert(c);
    }
  }
  return next_locs;
}

template <std::size_t N>
int
simulate(std::unordered_set<point<N>> const& input, int reps) {
  if (reps == 0) {
    return input.size();
  } else {
    return simulate(step(input), reps - 1);
  }
}

template <std::size_t N, std::size_t M>
point<N>
pad (point<M> const & in) {
  point<N> out;
  std::fill_n(out.data(), N, 0);
  std::copy_n(in.data(), M, out.data());
  return out;
}

std::unordered_set<point<3>>
parse_input(std::istream& is) {
  std::unordered_set<point<3>> input;
  int y {0};
  for (std::string line; std::getline(is, line); ) {
    int x {0};
    for (char c : line) {
      if (c == '#') {
        input.insert({x, y, 0});
      }
      ++x;
    }
    ++y;
  }
  return input;
}

int main() {
  auto input = parse_input(std::cin);
  
  std::unordered_set<point<4>> input2;
  for (point<3> const& i : input) {
    input2.insert(pad<4>(i));
  }

  std::cout << simulate(input, 6) << '\n'
            << simulate(input2, 6) << '\n';
  return 0;
}