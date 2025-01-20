pub const TILE_SIZE: u32 = 64;
pub const WINDOW_WIDTH: u16 = 1280;
pub const WINDOW_HEIGHT: u16 = 800;
pub const MAP_NUM_ROWS = 10;
pub const MAP_NUM_COLS = 10;
pub const FPS: u64 = 60;
pub const FRAME_TIME_LENGTH: u64 = (1000 / FPS);
pub const PI = 3.14159265;
pub const TWO_PI = PI * 2;
pub const NUM_RAYS = 1280;
pub const FOV_ANGLE = (60.0 * (PI / 180.0));
pub const DIST_PROJ_PLANE = ((@as(f32, WINDOW_WIDTH) / 2.0) / @tan(FOV_ANGLE / 2.0));
pub const MINIFY = 0.2;
