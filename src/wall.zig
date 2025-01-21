const constants = @import("constants.zig");
const std = @import("std");
const p = @import("player.zig");
const m = @import("map.zig");
const math = std.math;
const r = @import("ray.zig");
const utils = @import("utils.zig");
const c = @cImport(@cInclude("SDL3/SDL.h"));

pub fn render_walls(renderer: *c.SDL_Renderer, rays: *[constants.NUM_RAYS]r.Ray, player: *p.Player) void {
    for (rays, 0..) |ray, x| {
        // const temp = @as(f32, @floatFromInt(x)) - constants.NUM_RAYS / 2.0;
        // const ray_angle = player.rotation_angle + math.atan(temp / constants.DIST_PROJ_PLANE);

        const perp_distance: f32 = ray.distance * math.cos(ray.ray_angle - player.rotation_angle);
        const wall_height = (constants.TILE_SIZE / perp_distance) * @round(constants.DIST_PROJ_PLANE);
        const half_wall_height = wall_height / 2;
        var wall_top_y = (constants.HALF_WINDOW_HEIGHT) - (half_wall_height);
        wall_top_y = if (wall_top_y < 0) 0 else wall_top_y;
        var wall_bottom_y = (constants.HALF_WINDOW_HEIGHT) + (half_wall_height);
        wall_bottom_y = if (wall_bottom_y > constants.WINDOW_HEIGHT) constants.WINDOW_HEIGHT else wall_bottom_y;
        const wby: usize = @as(usize, @intFromFloat(wall_bottom_y));
        const wty: usize = @as(usize, @intFromFloat(wall_top_y));

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        for (0..wty) |y| {
            _ = c.SDL_RenderPoint(
                renderer,
                @floatFromInt(x),
                @floatFromInt(y),
            );
        }

        if (ray.wall_hit_content == 1) {
            _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0xFF, 0xFF);
        }

        if (ray.wall_hit_content == 2) {
            _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0x00, 0x00, 0xFF);
        }

        for (wty..wby) |y| {
            _ = c.SDL_RenderPoint(
                renderer,
                @floatFromInt(x),
                @floatFromInt(y),
            );
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

        for (wby..constants.WINDOW_HEIGHT) |y| {
            _ = c.SDL_RenderPoint(
                renderer,
                @floatFromInt(x),
                @floatFromInt(y),
            );
        }
    }
}
