const constants = @import("constants.zig");
const std = @import("std");
const math = std.math;

pub fn normalize_angle(angle: f32) f32 {
    var val = @rem(angle, constants.TWO_PI);
    if (val < 0) {
        val = constants.TWO_PI + val;
    }

    return val;
}

pub fn distance_between_points(x1: f32, y1: f32, x2: f32, y2: f32) f32 {
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}
