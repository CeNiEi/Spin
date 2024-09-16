const rl = @import("raylib");
const utils = @import("utils.zig");
const std = @import("std");
const Projectile = @import("projectile.zig").Projectile;

pub const Ship = struct {
    const sprite_size: struct { width: f32, height: f32 } = .{ .width = 33, .height = 21 };
    const SHIP_BUFFER: [7][11]u8 = .{
        [_]u8{ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 },
        [_]u8{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
        [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    position: rl.Vector2,
    texture: rl.Texture2D,

    speed: f32 = 5,

    moving_status: utils.MovingStatus = utils.MovingStatus.Stationary,
    living_status: utils.LivingStatus = utils.LivingStatus.Alive,
    shooting_status: utils.ShootingStatus = utils.ShootingStatus.NotShooting,

    projectiles: std.ArrayList(Projectile),

    pub fn init(position: rl.Vector2, alloc: std.mem.Allocator) Ship {
        const projectiles = std.ArrayList(Projectile).init(alloc);

        var image = rl.genImageColor(11, 7, rl.Color.blank);

        for (0..7) |row| {
            for (0..11) |col| {
                if (SHIP_BUFFER[row][col] == 1) {
                    rl.imageDrawPixel(&image, @as(i32, @intCast(col)), @as(i32, @intCast(row)), rl.Color.green);
                }
            }
        }

        rl.imageResizeNN(&image, sprite_size.width, sprite_size.height);

        const texture = rl.loadTextureFromImage(image);

        return .{
            .position = position,
            .texture = texture,
            .projectiles = projectiles,
        };
    }

    pub fn render(self: *Ship) void {
        rl.drawTextureV(self.texture, self.position, rl.Color.green);

        for (self.projectiles.items) |*projectile| {
            if (projectile.living_status == utils.LivingStatus.Alive) {
                projectile.render();
            }
        }
    }

    pub fn update(self: *Ship) !void {
        if (self.living_status == utils.LivingStatus.Dead) {
            return;
        }

        self.position.x += switch (self.moving_status) {
            utils.MovingStatus.Stationary => 0,
            utils.MovingStatus.Moving => |direction| switch (direction) {
                utils.Direction.Right => self.speed,
                utils.Direction.Left => -self.speed,
                else => 0,
            },
        };

        if (self.shooting_status == utils.ShootingStatus.Shooting) {
            try self.projectiles.append(Projectile.init(utils.addVec(&self.position, &rl.Vector2.init((sprite_size.width / 2), 0)), utils.Direction.Up));
        }

        for (self.projectiles.items) |*projectile| {
            if (projectile.living_status == utils.LivingStatus.Alive) {
                projectile.update();
            }
        }

        self.shooting_status = utils.ShootingStatus.NotShooting;
        self.moving_status = utils.MovingStatus.Stationary;
    }

    pub fn deinit(self: *Ship) void {
        self.projectiles.deinit();
    }
};
