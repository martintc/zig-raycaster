const std = @import("std");
const c = @cImport(@cInclude("SDL3/SDL.h"));
const constants = @import("constants.zig");
const math = std.math;
const map = @import("map.zig");

pub const Player = struct {
    x: f32,
    y: f32,
    rotation_angle: f32,
    turn_direction: i8,
    walk_direction: i8,
    walk_speed: f32,
    turn_speed: f32,

    pub fn init() Player {
        return Player{
            .x = 100.0,
            .y = 100.0,
            .rotation_angle = constants.PI / 2.0,
            .turn_direction = 0,
            .walk_direction = 0,
            .walk_speed = 100.0,
            .turn_speed = 60.0 * (constants.PI / 180.0),
        };
    }

    pub fn draw(self: *Player, renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0x00, 0x00, 0xFF);

        var rect: c.SDL_FRect = .{
            .x = self.x * constants.MINIFY,
            .y = self.y * constants.MINIFY,
            .w = 5.0 * constants.MINIFY,
            .h = 5.0 * constants.MINIFY,
        };

        _ = c.SDL_RenderFillRect(renderer, &rect);

        // _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0xFF, 0xFF);

        // _ = c.SDL_RenderLine(
        //     renderer,
        //     self.x + 2.5 * constants.MINIFY,
        //     self.y + 2.5 * constants.MINIFY,
        //     self.x + 2.5 + math.cos(self.rotation_angle) * 40 * constants.MINIFY,
        //     self.y + 2.5 + math.sin(self.rotation_angle) * 40 * constants.MINIFY,
        // );
    }

    pub fn move(self: *Player, dt: f64) void {
        const adjusted_dt: f32 = @floatCast(dt);
        self.rotation_angle += @as(f32, @floatFromInt(self.turn_direction)) * self.turn_speed * adjusted_dt;

        const move_step = @as(f64, @floatFromInt(self.walk_direction)) * self.walk_speed * adjusted_dt;

        const new_x: f32 = @floatCast(self.x + math.cos(self.rotation_angle) * move_step);
        const new_y: f32 = @floatCast(self.y + math.sin(self.rotation_angle) * move_step);

        if (map.has_wall_at(new_x, new_y)) {
            return;
        }

        self.x = new_x;
        self.y = new_y;
    }
};
