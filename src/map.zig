const std = @import("std");
const c = @cImport(@cInclude("SDL3/SDL.h"));
const constants = @import("constants.zig");

// const map_rows: u8 =

const map = [constants.MAP_NUM_ROWS][constants.MAP_NUM_COLS]u8{
    [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 1, 1, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    [_]u8{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
};

pub fn render_map_grid(renderer: *c.SDL_Renderer) void {
    for (map, 0..) |row, col_index| {
        for (row, 0..) |col, row_index| {
            const tile_x = row_index * constants.TILE_SIZE;
            const tile_y = col_index * constants.TILE_SIZE;

            if (col == 1) {
                _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xFF);
                var rect: c.SDL_FRect = .{
                    .x = @floatFromInt(tile_x),
                    .y = @floatFromInt(tile_y),
                    .w = constants.TILE_SIZE,
                    .h = constants.TILE_SIZE,
                };

                _ = c.SDL_RenderFillRect(renderer, &rect);
            }

            if (col == 0) {
                _ = c.SDL_SetRenderDrawColor(renderer, 0x21, 0x21, 0x21, 0xFF);
                var rect: c.SDL_FRect = .{
                    .x = @floatFromInt(tile_x),
                    .y = @floatFromInt(tile_y),
                    .w = constants.TILE_SIZE,
                    .h = constants.TILE_SIZE,
                };

                _ = c.SDL_RenderFillRect(renderer, &rect);
            }
        }
    }
}

pub fn has_wall_at(x: f32, y: f32) bool {
    if (x < 0 or
        x > constants.MAP_NUM_COLS * constants.TILE_SIZE or
        y < 0 or y > constants.MAP_NUM_ROWS * constants.TILE_SIZE)
    {
        return true;
    }

    const map_x_f = @floor(x / constants.TILE_SIZE);
    const map_y_f = @floor(y / constants.TILE_SIZE);
    const map_x: usize = @intFromFloat(map_x_f);
    const map_y: usize = @intFromFloat(map_y_f);

    return map[map_y][map_x] != 0;
}

pub fn is_in_map(x: f32, y: f32) bool {
    return (x >= 0 and
        x <= constants.MAP_NUM_COLS * constants.TILE_SIZE and
        y >= 0 and
        y <= constants.MAP_NUM_ROWS * constants.TILE_SIZE);
}
