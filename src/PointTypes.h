#pragma once

#include <optional>

struct DataPoint
{
    double x = 0.0;
    std::optional<double> y;
};

struct SegmentResult
{
    int startIndex = 0;
    int endIndex = 0;
    double xStart = 0.0;
    double xEnd = 0.0;
    double slope = 0.0;
    double intercept = 0.0;
    double rSquared = 0.0;
};
