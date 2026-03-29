# Code Export

This page explains how the computed piecewise segments become code strings.

The implementation lives in `src/CodeExportService.cpp`.

## Supported Targets

| Target | Function style |
| --- | --- |
| PLC | `IF / ELSIF / ELSE / END_IF` assignment |
| Python | `def piecewise_linear_fit(...)` |
| C++ | `double piecewiseLinearFit(...)` |
| JavaScript | `function piecewiseLinearFit(...)` |
| Java | `public static double piecewiseLinearFit(...)` |
| C# | `public static double PiecewiseLinearFit(...)` |

## Export Pipeline

```mermaid
flowchart LR
    A[SegmentResult list] --> B[AppController]
    B --> C[Resolve input/output names]
    C --> D[CodeExportService]
    D --> E[Target-specific conditional code]
```

## Common Export Pattern

All targets follow the same logic:

1. compare the input value against segment boundaries
2. compute `output = slope * input + intercept`
3. return or assign that result
4. use a fallback value of `0.0` below the first range

## Range Semantics

For all intermediate segments:

```text
input >= xStart and input < xEnd
```

For the final segment:

```text
input >= xStart
```

That means:

- values above the last segment are extrapolated by the last line
- values below the first segment fall back to zero

## PLC Example

```text
IF IN_VALUE >= x0 AND IN_VALUE < x1 THEN
    OUT_LONG := m0 * IN_VALUE + b0;
ELSIF IN_VALUE >= x1 AND IN_VALUE < x2 THEN
    OUT_LONG := m1 * IN_VALUE + b1;
ELSIF IN_VALUE >= x2 THEN
    OUT_LONG := m2 * IN_VALUE + b2;
ELSE
    OUT_LONG := 0.0;
END_IF
```

## Function-Based Targets

The non-PLC targets generate a function with:

- one input variable
- one local output variable
- a chain of conditional branches
- a final return

This keeps all targets structurally similar even though the syntax changes.

## CSV Header Naming Support

When CSV header naming is enabled in the UI:

- the input variable name is derived from the detected CSV input header
- the output variable name is derived from the detected CSV output header

If CSV header naming is disabled:

- generic fallback names are used

## Identifier Sanitization

The export service sanitizes requested names so they can be used as code identifiers.

The current rules are:

- keep ASCII letters
- keep digits after the first character
- keep `_`
- replace unsupported characters with `_`
- strip trailing underscores
- prepend `_` if the final identifier would start with a digit

This matters for headers such as:

- `Length_m`
- `Value Analog`
- `4-20mA Output`

## Formatting Rules

The export code also normalizes numeric formatting:

- near-zero values are converted to `0`
- trailing zeros are removed
- trailing decimal separators are removed

That keeps the generated output shorter and easier to paste into another environment.

## App Integration

`AppController` exposes:

- `exportTargets`
- `exportTarget`
- `exportCode`
- `plcCode`

The results page uses:

- a combo box to switch targets
- a text area to preview the generated code
- a copy button to place the result on the clipboard

## Practical Limits

- The code generator does not emit unit tests or wrappers.
- It assumes the computed segments are already valid.
- It uses current segment boundaries directly.
- It does not clamp outputs to a min/max range.
