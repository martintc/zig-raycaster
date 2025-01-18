const constants = @import("constants.zig");
const std = @import("std");
const p = @import("player.zig");
const utils = @import("utils.zig");
const math = std.math;
const map = @import("map.zig");
const c = @cImport(@cInclude("SDL3/SDL.h"));

pub const Ray = struct {
    ray_angle: f32,
    wall_hit_x: f32,
    wall_hit_y: f32,
    distance: f32,
    was_hit_vertical: bool,
    wall_hit_content: i8,

    pub fn is_ray_facing_down(angle: f32) bool {
        return angle > 0 and angle < constants.PI;
    }

    pub fn is_ray_facing_up(angle: f32) bool {
        return !is_ray_facing_down(angle);
    }

    pub fn is_ray_facing_right(angle: f32) bool {
        return angle < (0.5 * constants.PI) or angle > (1.5 * constants.PI);
    }

    pub fn is_ray_facing_left(angle: f32) bool {
        return !is_ray_facing_right(angle);
    }

    pub fn cast_ray(player: *p.Player, ray_angle: f32) Ray {
        const normalized_angle: f32 = utils.normalize_angle(ray_angle);

        var x_int: f32 = undefined;
        var y_int: f32 = undefined;
        var x_step: f32 = undefined;
        var y_step: f32 = undefined;

        var found_h_wall_hit: bool = false;
        var h_wall_hit_x: f32 = undefined;
        var h_wall_hit_y: f32 = undefined;
        //var h_wall_content: u8 = undefined;

        y_int = @floor(player.*.y / constants.TILE_SIZE) * constants.TILE_SIZE;
        y_int += if (is_ray_facing_down(normalized_angle)) constants.TILE_SIZE else 0;

        x_int = player.*.x + (y_int - player.*.y) / math.tan(normalized_angle);

        y_step = constants.TILE_SIZE;
        y_step *= if (is_ray_facing_up(normalized_angle)) -1 else 1;

        x_step = constants.TILE_SIZE / math.tan(normalized_angle);
        x_step *= if (is_ray_facing_left(normalized_angle) and x_step > 0) -1 else 1;
        x_step *= if (is_ray_facing_right(normalized_angle) and x_step < 0) -1 else 1;

        var next_h_touch_x = x_int;
        var next_h_touch_y = y_int;

        while (map.is_in_map(next_h_touch_x, next_h_touch_y)) {
            const val: f32 = if (is_ray_facing_up(normalized_angle)) -1.0 else 0.0;
            const x_to_check: f32 = next_h_touch_x;
            const y_to_check: f32 = next_h_touch_y + val;

            if (map.has_wall_at(x_to_check, y_to_check)) {
                h_wall_hit_x = next_h_touch_x;
                h_wall_hit_y = next_h_touch_y;

                found_h_wall_hit = true;
                break;
            } else {
                next_h_touch_x += x_step;
                next_h_touch_y += y_step;
            }
        }

        var found_v_wall_hit: bool = false;
        var v_wall_hit_x: f32 = undefined;
        var v_wall_hit_y: f32 = undefined;
        //var v_wall_hit_content: u8 = undefined;

        x_int = @floor(player.*.x / constants.TILE_SIZE) * constants.TILE_SIZE;
        x_int += if (is_ray_facing_right(normalized_angle)) constants.TILE_SIZE else 0;

        y_int = player.*.y + (x_int - player.*.x) * math.tan(normalized_angle);

        x_step = constants.TILE_SIZE;
        x_step *= if (is_ray_facing_left(normalized_angle)) -1 else 1;

        y_step = constants.TILE_SIZE * math.tan(normalized_angle);
        y_step *= if (is_ray_facing_up(normalized_angle) and y_step > 0) -1 else 1;
        y_step *= if (is_ray_facing_down(normalized_angle) and y_step < 0) -1 else 1;

        var next_v_touch_x: f32 = x_int;
        var next_v_touch_y: f32 = y_int;

        while (map.is_in_map(next_v_touch_x, next_v_touch_y)) {
            const val: f32 = if (is_ray_facing_left(normalized_angle)) -1.0 else 0.0;
            const x_to_check: f32 = next_v_touch_x + val;
            const y_to_check: f32 = next_v_touch_y;

            if (map.has_wall_at(x_to_check, y_to_check)) {
                v_wall_hit_x = next_v_touch_x;
                v_wall_hit_y = next_v_touch_y;

                found_v_wall_hit = true;
                break;
            } else {
                next_v_touch_x += x_step;
                next_v_touch_y += y_step;
            }
        }

        const h_hit_dist: f32 = if (found_h_wall_hit) utils.distance_between_points(player.*.x, player.*.y, h_wall_hit_x, h_wall_hit_y) else 30000.0;
        const v_hit_dist: f32 = if (found_v_wall_hit) utils.distance_between_points(player.*.x, player.*.y, v_wall_hit_x, v_wall_hit_y) else 30000.0;

        if (v_hit_dist < h_hit_dist) {
            const ray: Ray = .{
                .distance = v_hit_dist,
                .wall_hit_x = v_wall_hit_x,
                .wall_hit_y = v_wall_hit_y,
                .wall_hit_content = 0,
                .was_hit_vertical = true,
                .ray_angle = normalized_angle,
            };

            return ray;
        } else {
            const ray: Ray = .{
                .distance = h_hit_dist,
                .wall_hit_x = h_wall_hit_x,
                .wall_hit_y = h_wall_hit_y,
                .wall_hit_content = 0,
                .was_hit_vertical = false,
                .ray_angle = normalized_angle,
            };

            return ray;
        }
    }

    pub fn draw(self: *Ray, player: *p.Player, renderer: *c.SDL_Renderer) void {
        const dx = (self.wall_hit_x - player.*.x);
        const dy = (self.wall_hit_y - player.*.y);

        var longest_side: f32 = undefined;

        if (@abs(dx) >= @abs(dy)) {
            longest_side = @abs(dx);
        } else {
            longest_side = @abs(dy);
        }

        const inc_x = dx / longest_side;
        const inc_y = dy / longest_side;

        var cur_x: f32 = player.*.x;
        var cur_y: f32 = player.*.y;

        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0xFF, 0x00, 0xFF);

        for (0..@intFromFloat(longest_side)) |_| {
            _ = c.SDL_RenderPoint(
                renderer,
                cur_x,
                cur_y,
            );
            cur_x += inc_x;
            cur_y += inc_y;
        }
    }
};
