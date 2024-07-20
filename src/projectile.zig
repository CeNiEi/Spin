const rl = @import("raylib");
const utils = @import("utils.zig");

pub const Projectile = struct {
    const sprite_size: struct { width: f32, height: f32 } = .{ .width = 3, .height = 9 };
    const PROJECTILE_BUFFER: [3][1]u8 = .{
        [_]u8{1},
        [_]u8{1},
        [_]u8{1},
    };

    position: rl.Vector2,
    texture: rl.Texture2D,

    speed: f32 = 1,

    moving_status: utils.MovingStatus,
    living_status: utils.LivingStatus = utils.LivingStatus.Alive,

    pub fn init(position: rl.Vector2, direction: utils.Direction) Projectile {
        var image = rl.genImageColor(1, 3, rl.Color.blank);

        for (0..3) |row| {
            for (0..1) |col| {
                if (PROJECTILE_BUFFER[row][col] == 1) {
                    rl.imageDrawPixel(&image, @as(i32, @intCast(col)), @as(i32, @intCast(row)), rl.Color.black);
                }
            }
        }

        rl.imageResizeNN(&image, sprite_size.width, sprite_size.height * 2);

        const texture = rl.loadTextureFromImage(image);

        return .{ .position = position, .texture = texture, .moving_status = utils.MovingStatus{ .Moving = direction } };
    }

    pub fn render(self: *Projectile) void {
        rl.drawTextureV(self.texture, self.position, rl.Color.blue);
    }

    pub fn update(self: *Projectile) void {
        if (self.living_status == utils.LivingStatus.Dead) {
            return;
        }

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
