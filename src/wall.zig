const constants = @import("constants.zig");
const std = @import("std");
const p = @import("player.zig");
const m = @import("map.zig");
const math = std.math;
const r = @import("ray.zig");
const utils = @import("utils.zig");
const c = @cImport(@cInclude("SDL3/SDL.h"));

pub fn render_wall(renderer: *c.SDL_Renderer, ray: r.Ray, player: p.Player, id: usize) void {
    const perp_distance = ray.distance * math.cos(ray.ray_angle - player.rotation_angle);
    const wall_height = (constants.TILE_SIZE / perp_distance) * constants.DIST_PROJ_PLANE;
    var wall_top_y = @floor((constants.WINDOW_HEIGHT / 2) - (wall_height / 2));
    wall_top_y = if (wall_top_y < 0) 0 else wall_top_y;
    var wall_bottom_y = (constants.WINDOW_HEIGHT / 2) + (wall_height / 2);
    wall_bottom_y = if (wall_bottom_y > constants.WINDOW_HEIGHT) constants.WINDOW_HEIGHT else wall_bottom_y;
    const wby: usize = @as(usize, @intFromFloat(wall_bottom_y));
    const wty: usize = @as(usize, @intFromFloat(wall_top_y));

    _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
    for (0..wty) |y| {
        _ = c.SDL_RenderPoint(
            renderer,
            @floatFromInt(id),
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
            @floatFromInt(id),
            @floatFromInt(y),
        );
    }

    _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

    for (wby..constants.WINDOW_HEIGHT) |y| {
        _ = c.SDL_RenderPoint(
            renderer,
            @floatFromInt(id),
            @floatFromInt(y),
        );
    }
}

pub fn render_walls(renderer: *c.SDL_Renderer, rays: *[constants.NUM_RAYS]r.Ray, player: *p.Player) void {
    for (rays, 0..) |ray, i| {
        const perp_distance = ray.distance * math.cos(ray.ray_angle - player.rotation_angle);
        const wall_height = (constants.TILE_SIZE / perp_distance) * constants.DIST_PROJ_PLANE;
        var wall_top_y = @floor((constants.WINDOW_HEIGHT / 2) - (wall_height / 2));
        wall_top_y = if (wall_top_y < 0) 0 else wall_top_y;
        var wall_bottom_y = (constants.WINDOW_HEIGHT / 2) + (wall_height / 2);
        wall_bottom_y = if (wall_bottom_y > constants.WINDOW_HEIGHT) constants.WINDOW_HEIGHT else wall_bottom_y;
        const wby: usize = @as(usize, @intFromFloat(wall_bottom_y));
        const wty: usize = @as(usize, @intFromFloat(wall_top_y));

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        for (0..wty) |y| {
            _ = c.SDL_RenderPoint(
                renderer,
                @floatFromInt(i),
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
                @floatFromInt(i),
                @floatFromInt(y),
            );
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

        for (wby..constants.WINDOW_HEIGHT) |y| {
            _ = c.SDL_RenderPoint(
                renderer,
                @floatFromInt(i),
                @floatFromInt(y),
            );
        }
    }
}
