# Docker container to cause segfault in php 8.1.0 under valgrind

This small example demonstrates an invalid read in php 8.1.0 under valgrind.

## Update, it appears the behavior starts after this [PHP commit](https://github.com/php/php-src/commit/a0c44fbaf19841164c7984a6c21b364d391f3750)

## The script itself
```php
<?php $x = 'k1';
```

## To trigger the segfault
The crash under Valgrind occurs when either running or even linting the script.

## From the host
```bash
# Run the script
docker run -it \
    mgrunder/php81-segfault-demonstrator \
    bash -c "valgrind /tmp/php-src/sapi/cli/php /tmp/test.php"

# Lint the script
docker run -it \
    mgrunder/php81-segfault-demonstrator \
    bash -c "valgrind /tmp/php-src/sapi/cli/php -l /tmp/test.php"
```

## From inside the container
```bash
# Run the script
valgrind /tmp/php-src/sapi/cli/php /tmp/test.php

# Lint the script
valgrind /tmp/php-src/sapi/cli/php /tmp/test.php
```

## The crash itself
```bash
# valgrind /tmp/php-src/sapi/cli/php /tmp/test.php
==9== Memcheck, a memory error detector
==9== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==9== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==9== Command: /tmp/php-src/sapi/cli/php /tmp/test.php
==9==
==9== Invalid read of size 4
==9==    at 0x63C1E0: zend_interned_string_ht_lookup (zend_string.c:163)
==9==    by 0x63C1E0: zend_new_interned_string_request (zend_string.c:228)
==9==    by 0x63C1E0: zend_new_interned_string_request (zend_string.c:217)
==9==    by 0x597AB5: zval_make_interned_string (zend_compile.c:514)
==9==    by 0x597AB5: zend_insert_literal (zend_compile.c:526)
==9==    by 0x597AB5: zend_add_literal (zend_compile.c:547)
==9==    by 0x597DE8: zend_emit_op_tmp (zend_compile.c:2105)
==9==    by 0x5A9CEB: zend_compile_assign.isra.0 (zend_compile.c:3194)
==9==    by 0x5A2DBE: zend_compile_expr_inner (zend_compile.c:10068)
==9==    by 0x5A2DBE: zend_compile_expr (zend_compile.c:10185)
==9==    by 0x59E014: zend_compile_stmt (zend_compile.c:10027)
==9==    by 0x59DAFF: zend_compile_top_stmt (zend_compile.c:9913)
==9==    by 0x59DB77: zend_compile_top_stmt (zend_compile.c:9899)
==9==    by 0x59DB77: zend_compile_top_stmt (zend_compile.c:9889)
==9==    by 0x57D5CE: zend_compile (zend_language_scanner.c:620)
==9==    by 0x57ED49: compile_file (zend_language_scanner.c:656)
==9==    by 0x472B1A: phar_compile_file (phar.c:3351)
==9==    by 0x5BC9AC: zend_execute_scripts (zend.c:1756)
==9==  Address 0x77 is not stack'd, malloc'd or (recently) free'd
==9==
==9==
==9== Process terminating with default action of signal 11 (SIGSEGV): dumping core
==9==  Access not within mapped region at address 0x77
==9==    at 0x63C1E0: zend_interned_string_ht_lookup (zend_string.c:163)
==9==    by 0x63C1E0: zend_new_interned_string_request (zend_string.c:228)
==9==    by 0x63C1E0: zend_new_interned_string_request (zend_string.c:217)
==9==    by 0x597AB5: zval_make_interned_string (zend_compile.c:514)
==9==    by 0x597AB5: zend_insert_literal (zend_compile.c:526)
==9==    by 0x597AB5: zend_add_literal (zend_compile.c:547)
==9==    by 0x597DE8: zend_emit_op_tmp (zend_compile.c:2105)
==9==    by 0x5A9CEB: zend_compile_assign.isra.0 (zend_compile.c:3194)
==9==    by 0x5A2DBE: zend_compile_expr_inner (zend_compile.c:10068)
==9==    by 0x5A2DBE: zend_compile_expr (zend_compile.c:10185)
==9==    by 0x59E014: zend_compile_stmt (zend_compile.c:10027)
==9==    by 0x59DAFF: zend_compile_top_stmt (zend_compile.c:9913)
==9==    by 0x59DB77: zend_compile_top_stmt (zend_compile.c:9899)
==9==    by 0x59DB77: zend_compile_top_stmt (zend_compile.c:9889)
==9==    by 0x57D5CE: zend_compile (zend_language_scanner.c:620)
==9==    by 0x57ED49: compile_file (zend_language_scanner.c:656)
==9==    by 0x472B1A: phar_compile_file (phar.c:3351)
==9==    by 0x5BC9AC: zend_execute_scripts (zend.c:1756)
==9==  If you believe this happened as a result of a stack
==9==  overflow in your program's main thread (unlikely but
==9==  possible), you can try to increase the size of the
==9==  main thread stack using the --main-stacksize= flag.
==9==  The main thread stack size used in this run was 8388608.
==9==
==9== HEAP SUMMARY:
==9==     in use at exit: 1,820,807 bytes in 12,974 blocks
==9==   total heap usage: 13,979 allocs, 1,005 frees, 2,388,778 bytes allocated
==9==
==9== LEAK SUMMARY:
==9==    definitely lost: 23,328 bytes in 729 blocks
==9==    indirectly lost: 40 bytes in 1 blocks
==9==      possibly lost: 1,470,768 bytes in 10,797 blocks
==9==    still reachable: 326,671 bytes in 1,447 blocks
==9==         suppressed: 0 bytes in 0 blocks
==9== Rerun with --leak-check=full to see details of leaked memory
==9==
==9== For lists of detected and suppressed errors, rerun with: -s
==9== ERROR SUMMARY: 1 errors from 1 contexts (suppressed: 0 from 0)
Segmentation fault (core dumped)
```
