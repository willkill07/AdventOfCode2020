BEGIN {
    tree = "#"
}
{
    width = NR - 1
    if (substr($0, width % 31 + 1, 1) == tree) a[1]++;
    if (substr($0, 3*width % 31 + 1, 1) == tree) a[3]++;
    if (substr($0, 5*width % 31 + 1, 1) == tree) a[5]++;
    if (substr($0, 7*width % 31 + 1, 1) == tree) a[7]++;
    # check every other line. Only advance over by one each time
    if (NR % 2 == 1 && substr($0, (NR / 2) % 31 + .5, 1) == tree) a[2]++
}
END {
    print a[3]
    print a[1] * a[3] * a[5] * a[7] * a[2]
}
