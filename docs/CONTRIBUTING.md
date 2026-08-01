# Contributing

1.  Create a branch from `main`.
2.  Add or update tests for every behavior change.
3.  Run
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html),
    [`devtools::test()`](https://devtools.r-lib.org/reference/test.html),
    and
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html).
4.  Avoid changing the independent analysis unit away from
    environment/environment-year without an explicit statistical model.
5.  Submit a pull request describing input assumptions, failure
    handling, and any backward-incompatible changes.
