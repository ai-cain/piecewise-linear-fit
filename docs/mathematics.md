# Mathematics

This page collects the mathematical ideas behind the current implementation.

## Notation

For a segment candidate with `n` points:

- `x_i`: input value of point `i`
- `y_i`: output value of point `i`
- `ŷ_i`: predicted output from the candidate line
- `e_i`: absolute error at point `i`

## Linear Regression Per Candidate

The line fitted to a candidate window is:

```text
ŷ = m x + b
```

where:

```text
m = (n Σ(x_i y_i) - Σx_i Σy_i) / (n Σ(x_i^2) - (Σx_i)^2)
b = (Σy_i - m Σx_i) / n
```

The implementation rejects a candidate if the denominator of `m` is too close to zero.

## Coefficient Of Determination

The service uses the classical `R^2` definition:

```text
SS_res = Σ(y_i - ŷ_i)^2
SS_tot = Σ(y_i - ȳ)^2
R^2 = 1 - SS_res / SS_tot
```

with `ȳ` as the mean of the observed outputs in the candidate window.

Practical handling:

- if `SS_tot` is near zero and `SS_res` is also near zero, `R^2` is treated as `1`
- otherwise the value is clamped to the interval `[0, 1]`

## Absolute Tolerance Used By The Segmentation

The algorithm derives its working tolerance from the output scale of the full dataset:

```text
maxAbsY = max |y_i|
absoluteTolerance = fitTolerancePercent * maxAbsY / 100
```

With the current default:

```text
fitTolerancePercent = 0.01
```

so the absolute fit tolerance is `0.01%` of the largest absolute output magnitude.

## Point-Wise Acceptance

For a candidate line, each point is tested by:

```text
e_i = |ŷ_i - y_i|
```

and mapped to a binary acceptance value:

```text
a_i = 1  if e_i <= absoluteTolerance
a_i = 0  otherwise
```

This creates a sequence such as:

```text
[1, 1, 1, 0, 0, 1]
```

## Longest Valid Run

Instead of summing all accepted points, the algorithm scores the candidate by the longest consecutive run of `1`s.

If:

```text
A = [a_1, a_2, ..., a_n]
```

then the candidate score is:

```text
score(A) = max length of any contiguous subsequence of 1s
```

Example:

```text
[1, 1, 0, 1, 1, 1] -> score = 3
```

This favors locally consistent line behavior over scattered acceptance.

## Conservative Segment Selection

The implementation tracks:

- the candidate with the best valid-run score
- the candidate with the best `R^2`

Then it chooses:

```text
chosenCount = min(bestCountByRun, bestCountByR2)
```

This is a heuristic compromise:

- valid-run scoring enforces local consistency
- `R^2` rewards overall regression quality

## Shared Boundary Points

After selecting a segment of size `chosenCount`, the cursor moves by:

```text
chosenCount - 1
```

So if one segment covers:

```text
[x_0, x_1, x_2, x_3, x_4]
```

the next segment starts again from `x_4`.

This is not a mathematical requirement of piecewise linear fitting in general, but it is part of the current heuristic and helps preserve visual continuity.

## Residuals Used By The UI

### Segment residuals

For a point belonging to a final segment:

```text
r_i = y_i - (m x_i + b)
```

These residuals are used in the segment error chart.

### Global residuals

The global residual chart uses a single reference line built from anchor points rather than a regression over all points.

The residual is:

```text
r_i(global) = y_i - (m_global x_i + b_global)
```

## Review Thresholds In The Results UI

The results page uses two thresholds derived from `maxAbsY`.

### Review band

```text
reviewTolerance = 0.2 * maxAbsY / 100
```

This is the symmetric band drawn around zero in the segment residual chart.

### Outlier marker threshold

For residual review, the code also computes a relative error percentage:

```text
errorPercent = 100 * |residual| / maxAbsY
```

A point is highlighted when:

```text
errorPercent > 0.1
```

That means the marker threshold is currently `0.1%` of the dataset output scale.

## What The Math Optimizes In Practice

The current implementation does not solve a single global optimization problem over all possible segmentations.

Instead it uses:

- local least-squares regression
- local tolerance acceptance
- a longest-run heuristic
- a conservative segment-size decision

So the mathematics is partly exact at the candidate level and partly heuristic at the segmentation level.
