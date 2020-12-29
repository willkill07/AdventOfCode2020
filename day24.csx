
var filename = Environment.GetCommandLineArgs()[2];
static var dirs = new Dictionary<string,(int,int,int)> {
    {"e"  , (1, 0, -1) },
    {"w"  , (-1, 0, 1) },
    {"se" , (0, 1, -1) },
    {"sw" , (-1, 1, 0) },
    {"nw" , (0, -1, 1) },
    {"ne" , (1, -1, 0) }
};

class Tile {
    public (int,int,int) Location { get; protected set; }

    public Tile(string dirList) {
        var loc = (0, 0, 0);
        var dir = "";
        foreach (var c in dirList) {
            if (c == 'n' || c == 's') {
                dir += c;
                continue;
            }
            dir += c;
            var d = dirs[dir];
            loc = (loc.Item1 + d.Item1, loc.Item2 + d.Item2, loc.Item3 + d.Item3);
            dir = "";
        }
        Location = loc;
    }

    public override bool Equals(object obj) {
        return this.Equals(obj as Tile);
    }

    public bool Equals(Tile o) {
        return Location.Equals(o.Location);
    }

    public override int GetHashCode() {
        return Location.GetHashCode();
    }

    public static Tile operator +(Tile t, (int,int,int) dir) {
        Tile newTile = (Tile)t.MemberwiseClone();
        newTile.Location = (t.Location.Item1 + dir.Item1, t.Location.Item2 + dir.Item2, t.Location.Item3 + dir.Item3 );
        return newTile;
    }
}

var tiles = File.ReadLines(filename) // read all lines
    .Select(line => new Tile(line)) // make the tile from direction list
    .GroupBy(tile => tile.Location) // group by location
    .Where(group => group.Count(x => true) % 2 == 1) // ensure odd count
    .Select(x => x.First()) // keep the first element of the group
    .ToDictionary(x => x.Location);

// part 1
Console.WriteLine(tiles.Count);

foreach (var i in Enumerable.Range(0, 100)) {
    tiles = tiles
        .SelectMany(t => dirs.Select(d => t.Value + d.Value)) // get all neighbors
        .Distinct() // remove duplicates
        .Where(t => {
            var neighborCount = dirs.Select(d => t + d.Value).Count(neighbor => tiles.ContainsKey(neighbor.Location));
            //     black IFF count == 2 or when black and count == 1
            return neighborCount == 2 || tiles.ContainsKey(t.Location) && neighborCount == 1;
        })
        .ToDictionary(x => x.Location);
}

// part 2
Console.WriteLine(tiles.Count);