const rl = @import("raylib");
const std = @import("std");

pub const MovingStatus = union(enum) { Stationary: void, Moving: Direction };

pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn reverse(self: *Direction) Direction {
        return switch (self.*) {
            .Right => Direction.Left,
            .Left => Direction.Right,
            .Up => Direction.Down,
            .Down => Direction.Up,
        };
    }
};

pub const LivingStatus = union(enum) { Alive: void, Dead: void, Dying: u32 };

pub const ShootingStatus = enum { Shooting, NotShooting };

pub fn addVec(lhs: *const rl.Vector2, rhs: *const rl.Vector2) rl.Vector2 {
    return rl.Vector2.init(lhs.x + rhs.x, lhs.y + rhs.y);
}

pub fn closeEnough(lhs: *const rl.Vector2, rhs: *const rl.Vector2) bool {
    const TOLERANCE = 20;

    return @abs(lhs.x - rhs.x) <= TOLERANCE and @abs(lhs.y - rhs.y) <= TOLERANCE;
}

pub fn reached_horizontal_boundary(position: rl.Vector2) bool {
    const width = SCREEN_WIDTH;
    const EXTREME = 10;

    return (position.x < width / EXTREME or position.x > width - width / EXTREME);
}

pub const SCREEN_WIDTH: f32 = 672;
pub const SCREEN_HEIGHT: f32 = 768;
