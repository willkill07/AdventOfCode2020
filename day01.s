  .text
solve:
  pushq %rbp
  pushq %r15
  pushq %r14
  pushq %r13
  pushq %r12
  pushq %rbx
  pushq %rax
  testq %r8, %r8
  js .fail
  movq %r8, %r12
  movq %rcx, %r15
  movq %r8, %rcx
  orq %r15, %rcx
  je .success          # level == 0 && target == 0
  movq %rsi, %rbx
  testq %rsi, %rsi
  jle .fail            # no more elements -> fail!
  movq %rdx, %r13      # r13 is caller-saved rdx
  movq %rdi, %rbp      # rbp serves as a local array base
  decq %r15            # r15 serves as a local "level"
  movq (%rdx), %r14    # save old product
.loop:
  leaq -1(%rbx), %rsi
  movq (%rbp), %rax
  movq %r14, %rcx
  imulq %rax, %rcx
  movq %rcx, (%r13)
  movq %r12, %r8
  subq %rax, %r8
  movq %rbp, %rdi
  movq %r13, %rdx
  movq %r15, %rcx
  callq solve
  testq %rax, %rax
  jne .success
  movq %r14, (%r13)    # restore old product
  addq $8, %rbp
  decq %rbx
  jg .loop
.fail:
  xorl %eax, %eax
  jmp .finished
.success:
  movl $1, %eax
.finished:
  addq $8, %rsp
  popq %rbx
  popq %r12
  popq %r13
  popq %r14
  popq %r15
  popq %rbp
  retq

part1:
  pushq %rbx
  subq $16, %rsp
  leaq 8(%rsp), %rbx
  movq $1, (%rbx)
  movl $ARRAY, %edi
  movl N(%rip), %esi
  movq %rbx, %rdx
  movl $2, %ecx
  movl $2020, %r8d
  callq solve
  movq (%rbx), %rax
  addq $16, %rsp
  popq %rbx
  retq

part2:
  pushq %rbx
  subq $16, %rsp
  leaq 8(%rsp), %rbx
  movq $1, (%rbx)
  movl $ARRAY, %edi
  movl N(%rip), %esi
  movq %rbx, %rdx
  movl $3, %ecx
  movl $2020, %r8d
  callq solve
  movq (%rbx), %rax
  addq $16, %rsp
  popq %rbx
  retq

  .globl main
main:
  pushq %rax
  callq part1
  movl $OUT_STR, %edi
  movq %rax, %rsi
  xorl %eax, %eax
  callq printf

  callq part2
  movl $OUT_STR, %edi
  movq %rax, %rsi
  xorl %eax, %eax
  callq printf

  xorl %eax, %eax
  popq %rcx
  retq

  .data
  .p2align 4
ARRAY:
  .quad 1313
  .quad 1968
  .quad 1334
  .quad 1566
  .quad 820
  .quad 1435
  .quad 1369
  .quad 1230
  .quad 1383
  .quad 1816
  .quad 1396
  .quad 1974
  .quad 1911
  .quad 1989
  .quad 1824
  .quad 1430
  .quad 1709
  .quad 1204
  .quad 1792
  .quad 1800
  .quad 1703
  .quad 2009
  .quad 1467
  .quad 1400
  .quad 1315
  .quad 1985
  .quad 1598
  .quad 1215
  .quad 1574
  .quad 1770
  .quad 1870
  .quad 1352
  .quad 1544
  .quad 1339
  .quad 188
  .quad 1347
  .quad 1986
  .quad 2003
  .quad 1538
  .quad 1839
  .quad 1688
  .quad 1350
  .quad 1191
  .quad 1961
  .quad 1578
  .quad 1946
  .quad 1548
  .quad 1975
  .quad 1745
  .quad 1631
  .quad 1390
  .quad 1811
  .quad 1586
  .quad 1409
  .quad 247
  .quad 1600
  .quad 1565
  .quad 1929
  .quad 1854
  .quad 1602
  .quad 1773
  .quad 1815
  .quad 1887
  .quad 1689
  .quad 1266
  .quad 1573
  .quad 1534
  .quad 1939
  .quad 1909
  .quad 1273
  .quad 1386
  .quad 1713
  .quad 1268
  .quad 1611
  .quad 1348
  .quad 1478
  .quad 1857
  .quad 1916
  .quad 1113
  .quad 936
  .quad 1603
  .quad 1716
  .quad 1875
  .quad 1855
  .quad 1834
  .quad 1701
  .quad 1279
  .quad 1346
  .quad 1503
  .quad 1797
  .quad 1287
  .quad 1447
  .quad 1475
  .quad 1950
  .quad 1614
  .quad 1261
  .quad 1442
  .quad 1299
  .quad 1465
  .quad 896
  .quad 1481
  .quad 1804
  .quad 1931
  .quad 1849
  .quad 1675
  .quad 1726
  .quad 355
  .quad 1485
  .quad 1343
  .quad 1697
  .quad 1735
  .quad 1858
  .quad 1205
  .quad 1345
  .quad 1281
  .quad 253
  .quad 1808
  .quad 1557
  .quad 1964
  .quad 1771
  .quad 1891
  .quad 1583
  .quad 1896
  .quad 1398
  .quad 1930
  .quad 1258
  .quad 1338
  .quad 1208
  .quad 1328
  .quad 1493
  .quad 1963
  .quad 1374
  .quad 1212
  .quad 1223
  .quad 1501
  .quad 2004
  .quad 1591
  .quad 1954
  .quad 115
  .quad 1972
  .quad 1814
  .quad 1643
  .quad 1270
  .quad 1349
  .quad 1297
  .quad 1399
  .quad 1969
  .quad 1237
  .quad 1228
  .quad 1379
  .quad 1779
  .quad 1765
  .quad 1427
  .quad 1464
  .quad 1247
  .quad 1967
  .quad 1577
  .quad 1719
  .quad 1559
  .quad 1274
  .quad 1879
  .quad 1504
  .quad 1732
  .quad 1277
  .quad 1758
  .quad 1721
  .quad 1936
  .quad 1605
  .quad 1358
  .quad 1505
  .quad 1411
  .quad 1823
  .quad 1576
  .quad 1682
  .quad 1439
  .quad 1901
  .quad 1940
  .quad 1760
  .quad 1414
  .quad 1193
  .quad 1900
  .quad 1990
  .quad 1781
  .quad 1801
  .quad 1239
  .quad 1729
  .quad 1360
  .quad 1780
  .quad 1848
  .quad 1468
  .quad 1484
  .quad 1280
  .quad 1278
  .quad 1851
  .quad 1903
  .quad 1894
  .quad 1731
  .quad 1451
  .quad 549
  .quad 1570

  .p2align 3
N:
  .quad 200

OUT_STR:
  .asciz "%lld\n"
