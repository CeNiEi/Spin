const rl = @import("raylib");
const utils = @import("utils.zig");

pub const Projectile = struct {
    const sprite_size: struct { width: f32, height: f32 } = .{ .width = 6, .height = 20 };
    const PROJECTILE_BUFFER: [15][3]u8 = .{
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 1, 1, 1 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },

        [_]u8{ 1, 1, 1 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },

        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 0, 1, 0 },
        [_]u8{ 1, 1, 1 },
    };

    position: rl.Vector2,
    texture: rl.Texture2D,

    speed: f32 = 1,

    sprite_frame: usize = 0,

    moving_status: utils.MovingStatus,
    living_status: utils.LivingStatus = utils.LivingStatus.Alive,

    pub fn init(position: rl.Vector2, direction: utils.Direction) Projectile {
        var image = rl.genImageColor(3, 15, rl.Color.blank);

        for (0..15) |row| {
            for (0..3) |col| {
                if (PROJECTILE_BUFFER[row][col] == 1) {
                    rl.imageDrawPixel(&image, @as(i32, @intCast(col)), @as(i32, @intCast(row)), rl.Color.black);
                }
            }
        }

        rl.imageResizeNN(&image, sprite_size.width, sprite_size.height * 3);

        const texture = rl.loadTextureFromImage(image);

        return .{
            .position = position,
            .texture = texture,
            .moving_status = utils.MovingStatus{ .Moving = direction },
        };
    }

    pub fn render(self: *Projectile) void {
        const roi = rl.Rectangle
            .init(0, @as(f32, @floatFromInt(self.sprite_frame / 15 % 3)) * Projectile.sprite_size.height, Projectile.sprite_size.width, Projectile.sprite_size.height);

        rl.drawTextureRec(self.texture, roi, self.position, rl.Color.black);
    }

    pub fn update(self: *Projectile) void {
        self.sprite_frame = (self.sprite_frame + 1) % 45;

        self.position.y += switch (self.moving_status) {
            utils.MovingStatus.Moving => |direction| switch (direction) {
                utils.Direction.Up => -self.speed,
                utils.Direction.Down => self.speed,
                else => 0,
            },
            utils.MovingStatus.Stationary => unreachable,
        };
    }
};
