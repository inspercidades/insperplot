# statistical plots reject continuous fill mappings

    Code
      insper_density(iris, x = Sepal.Length, fill = Sepal.Width)
    Condition
      Error in `insper_density()`:
      ! `fill` must be discrete for a density plot.
      i Convert the grouping variable to a factor.

---

    Code
      insper_histogram(iris, x = Sepal.Length, fill = Sepal.Width)
    Condition
      Error in `insper_histogram()`:
      ! `fill` must be discrete for a histogram.
      i Convert the grouping variable to a factor.
