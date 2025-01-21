const std = @import("std");
const c = @cImport(@cInclude("SDL3/SDL.h"));
const constants = @import("constants.zig");
const p = @import("player.zig");
const map = @import("map.zig");
const r = @import("ray.zig");
const w = @import("wall.zig");

pub const Game = struct {
    window: *c.SDL_Window,
    renderer: *c.SDL_Renderer,
    player: p.Player,
    quit: bool,
    ticks_last_frame: i32,
    rays: [constants.NUM_RAYS]r.Ray,

    pub fn init() Game {
        return .{
            .window = undefined,
            .renderer = undefined,
            .player = undefined,
            .quit = false,
            .ticks_last_frame = 0,
            .rays = undefined,
        };
    }

    pub fn setup(self: *Game) !void {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != true) {
            c.SDL_Log("Error: %s\n", c.SDL_GetError());
            return error.SDLInitializationError;
        }

        self.window = c.SDL_CreateWindow(
            "Window",
            constants.WINDOW_WIDTH,
            constants.WINDOW_HEIGHT,
            0,
        ) orelse {
            c.SDL_Log("Error: %s\n", c.SDL_GetError());
            return error.SDLInitializationError;
        };

        self.renderer = c.SDL_CreateRenderer(self.window, null) orelse {
            c.SDL_Log("Error: %s\n", c.SDL_GetError());
            return error.SDLInitializationError;
        };

        self.player = p.Player.init();

        var rays: [constants.NUM_RAYS]r.Ray = undefined;
        for (0..constants.NUM_RAYS) |i| {
            rays[i] = .{
                .ray_angle = undefined,
                .wall_hit_x = undefined,
                .wall_hit_y = undefined,
                .distance = undefined,
                .was_hit_vertical = undefined,
                .wall_hit_content = undefined,
            };
        }

        self.rays = rays;
    }

    pub fn deinit(self: *Game) void {
        c.SDL_DestroyRenderer(self.renderer);
        c.SDL_DestroyWindow(self.window);
        c.SDL_Quit();
    }

    fn update(self: *Game) void {
        const current_ticks: i64 = @intCast(c.SDL_GetTicks());
        const time_to_wait: i64 = 33 - (current_ticks - self.ticks_last_frame);

        if (time_to_wait > 0 and time_to_wait <= constants.FRAME_TIME_LENGTH) {
            _ = c.SDL_Delay(@intCast(time_to_wait));
        }

        const dt = @as(f64, @floatFromInt((current_ticks - self.ticks_last_frame))) / 1000.0;

        self.ticks_last_frame = @truncate(current_ticks);

        self.player.move(dt);

        for (0..constants.NUM_RAYS) |i| {
            const strip: f32 = @floatFromInt(i);
            const angle = self.player.rotation_angle + @tan((strip - constants.NUM_RAYS / 2) / constants.DIST_PROJ_PLANE);

            self.rays[i] = r.Ray.cast_ray(&self.player, angle);
        }
    }

    fn draw_mini_map(self: *Game) void {
        map.render_map_grid(self.renderer);
        self.player.draw(self.renderer);

        for (0..constants.NUM_RAYS) |i| {
            self.rays[i].draw(&self.player, self.renderer);
        }
    }

    fn draw(self: *Game) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0x21, 0x21, 0x21, 0xFF);
        _ = c.SDL_RenderClear(self.renderer);

        w.render_walls(self.renderer, &self.rays, &self.player);

        // self.draw_mini_map();

        _ = c.SDL_RenderPresent(self.renderer);
    }

    fn process_input(self: *Game) void {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != false) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => self.quit = true,
                c.SDL_EVENT_KEY_DOWN => {
                    switch (event.key.key) {
                        c.SDLK_ESCAPE => self.quit = true,
                        c.SDLK_W => self.player.walk_direction = 1,
                        c.SDLK_A => self.player.turn_direction = -1,
                        c.SDLK_S => self.player.walk_direction = -1,
                        c.SDLK_D => self.player.turn_direction = 1,
                        else => {},
                    }
                },
                c.SDL_EVENT_KEY_UP => {
                    switch (event.key.key) {
                        c.SDLK_W => self.player.walk_direction = 0,
                        c.SDLK_S => self.player.walk_direction = 0,
                        c.SDLK_A => self.player.turn_direction = 0,
                        c.SDLK_D => self.player.turn_direction = 0,
                        else => {},
                    }
                },
                else => {},
            }
        }
    }

    pub fn run(self: *Game) void {
        while (!self.quit) {
            self.process_input();
            self.update();
            self.draw();
        }
    }
};
