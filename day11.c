#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

typedef int (*count_fn_t) (char const*, int, int, int, int);
typedef bool (*check_fn_t) (char, int);

void calculate_dims(FILE* f, int* rows, int* cols) {
  fseek(f, 0, SEEK_END);
  int size = ftell(f);
  fseek(f, 0, SEEK_SET);
  int c = 0;
  while (fgetc(f) != '\n') {
    ++c;
  }
  *cols = c;
  *rows = size / (c + 1);
  fseek(f, 0, SEEK_SET);
}

char* init_board(FILE* f, int rows, int cols) {
  int const elems = rows * cols;
  char* board = (char*)malloc(sizeof(char) * elems);
  memset(board, '.', elems);
  char* base = board;
  for (int r = 0; r < rows; ++r) {
    fread(base, 1, cols, f);
    base += cols;
    fseek(f, 1, SEEK_CUR);
  }
  return board;
}

char* dup_board(char* board, int rows, int cols) {
  int const elems = rows * cols;
  char* newBoard = (char*)malloc(sizeof(char) * elems);
  memcpy(newBoard, board, elems);
  return newBoard;
}

const int dirs[8][2] = {{-1, -1}, {-1, 0}, {-1, 1},
                        { 0, -1},          { 0, 1},
                        { 1, -1}, { 1, 0}, { 1, 1}};

int count_neighbors (char const* origin, int r, int c, int rows, int cols) {
  int count = 0;
  for (int d = 0; d < 8; ++d) {
    int const dr = dirs[d][0];
    int const dc = dirs[d][1];
    int const ir = r + dr;
    int const ic = c + dc;
    if (0 <= ir && ir < rows && 0 <= ic && ic < cols && origin[ir * cols + ic] == '#') {
      ++count;
    }
  }
  return count;
}

int count_neighbors2 (char const* origin, int r, int c, int rows, int cols) {
  int count = 0;
  for (int d = 0; d < 8; ++d) {
    int const dr = dirs[d][0];
    int const dc = dirs[d][1];
    for (int ir = r + dr, ic = c + dc; 0 <= ir && ir < rows && 0 <= ic && ic < cols; ir += dr, ic += dc) {
      int const idx = ir * cols + ic;
      if (origin[idx] == '.') {
        continue;
      }
      count += (origin[idx] == '#');
      break;
    }
  }
  return count;
}

bool check (char c, int count) {
  return (c == 'L' && count == 0) || (c == '#' && count < 4);
}

bool check2 (char c, int count) {
  return (c == 'L' && count == 0) || (c == '#' && count < 5);
}

bool evolve(char* new_board, char* old_board, int rows, int cols, count_fn_t fn, check_fn_t cmp) {
  for (int r = 0; r < rows; ++r) {
    for (int c = 0; c < cols; ++c) {
      int const idx = r * cols + c;
      if (old_board[idx] == '.') {
        continue;
      }
      int const neighbors = fn(old_board, r, c, rows, cols);
      if (cmp(old_board[idx], neighbors)) {
        new_board[idx] = '#';
      } else {
        new_board[idx] = 'L';
      }
    }
  }
  return memcmp(new_board, old_board, rows * cols);
}

int simulate(char* board, int rows, int cols, count_fn_t fn, check_fn_t check) {
  char* old_board = dup_board(board, rows, cols);
  char* new_board = dup_board(board, rows, cols);
  while (evolve(new_board, old_board, rows, cols, fn, check)) {
    char* b = old_board;
    old_board = new_board;
    new_board = b;
  }
  int total = 0;
  int const elems = rows * cols;
  for (int i = 0; i < elems; ++i) {
    if (new_board[i] == '#') {
      ++total;
    }
  }
  free(new_board);
  free(old_board);
  return total;
}

int main(int argc, char* argv[]) {
  // choose from stdin or command line arg
  FILE* f = (argc > 1) ? fopen(argv[1], "r") : stdin;
  if (!f) {
    return 1;
  }
  int rows, cols;
  calculate_dims(f, &rows, &cols);
  char* board = init_board(f, rows, cols);
  if (f != stdin) {
    fclose(f);
  }
  int part1 = simulate(board, rows, cols, &count_neighbors,  &check);
  int part2 = simulate(board, rows, cols, &count_neighbors2, &check2);
  printf("%d\n", part1);
  printf("%d\n", part2);
  free(board);
  return 0;
}