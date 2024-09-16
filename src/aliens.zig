const rl = @import("raylib");
const utils = @import("utils.zig");
const std = @import("std");
const Projectile = @import("projectile.zig").Projectile;

const Alien = struct {
    const ALIEN_BUFFER: [24][11]u8 = .{
        [_]u8{ 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0 },
        [_]u8{ 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 },
        [_]u8{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
        [_]u8{ 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0 },
        [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u8{ 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1 },
        [_]u8{ 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1 },
        [_]u8{ 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0 },

        [_]u8{ 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0 },
        [_]u8{ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1 },
        [_]u8{ 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1 },
        [_]u8{ 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1 },
        [_]u8{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u8{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
        [_]u8{ 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0 },
        [_]u8{ 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 },

        [_]u8{ 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0 },
        [_]u8{ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
        [_]u8{ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1 },
        [_]u8{ 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 },
        [_]u8{ 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 },
        [_]u8{ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1 },
        [_]u8{ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
        [_]u8{ 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0 },
    };

    const sprite_size: struct { width: f32, height: f32 } = .{ .width = 33, .height = 24 };
    position: rl.Vector2,
    texture: rl.Texture2D,

    speed: f32 = 3,

    sprite_frame: usize = 0,

    living_status: utils.LivingStatus = utils.LivingStatus.Alive,

    pub fn init(position: rl.Vector2) Alien {
        var image = rl.genImageColor(11, 24, rl.Color.blank);

        for (0..24) |row| {
            for (0..11) |col| {
                if (ALIEN_BUFFER[row][col] == 1) {
                    rl.imageDrawPixel(&image, @as(i32, @intCast(col)), @as(i32, @intCast(row)), rl.Color.red);
                }
            }
        }

        rl.imageResizeNN(&image, sprite_size.width, Alien.height * 3);

        const texture = rl.loadTextureFromImage(image);

        return .{
            .position = position,
            .texture = texture,
        };
    }

    pub fn update(self: *Alien, direction: utils.Direction) void {
        self.sprite_frame = (self.sprite_frame + 1) % 2;

        switch (self.living_status) {
            .Dying => |v| {
                if (v >= 1) {
                    self.living_status = .Dead;
                } else {
                    self.living_status.Dying = v + 1;
                }
            },
            else => {},
        }

        switch (direction) {
            utils.Direction.Up => self.position.y -= self.speed,
            utils.Direction.Down => self.position.y += self.speed,
            utils.Direction.Right => self.position.x += self.speed,
            utils.Direction.Left => self.position.x -= self.speed,
        }
    }

    pub fn render(self: *Alien) void {
        var sprite_frame = self.sprite_frame;

        if (self.living_status == utils.LivingStatus.Dying) {
            sprite_frame = 2;
        }

        const roi = rl.Rectangle
            .init(0, @as(f32, @floatFromInt(sprite_frame)) * Alien.sprite_size.height, Alien.sprite_size.width, Alien.sprite_size.height);

        rl.drawTextureRec(self.texture, roi, self.position, rl.Color.red);
    }
};

pub const AlienHorde = struct {
    aliens: std.ArrayList(Alien),
    ctx: struct { counter: u64, current_direction: utils.Direction, next_direction: ?utils.Direction } = .{ .counter = 0, .current_direction = utils.Direction.Right, .next_direction = null },
    projectiles: std.ArrayList(Projectile),
    columns_remaining: i32,
    shooting_ctx: struct { shooter: i32, counter: u32 },

    pub fn init(alloc: std.mem.Allocator) !AlienHorde {
        var aliens = std.ArrayList(Alien).init(alloc);
        const projectiles = std.ArrayList(Projectile).init(alloc);

        const padding_x = utils.SCREEN_WIDTH / 10;
        const padding_y = utils.SCREEN_HEIGHT / 10;

        for (0..5) |row| {
            for (0..11) |col| {
                try aliens
                    .append(Alien.init(rl.Vector2.init(48 * @as(f32, @floatFromInt(col)) + padding_x, 32 * @as(f32, @floatFromInt(5 - 1 - row)) + padding_y)));
            }
        }

        const columns_remaining = 11;
        const shooting_ctx = .{ .shooter = rl.getRandomValue(0, columns_remaining - 1), .counter = 0 };

        return .{ .aliens = aliens, .projectiles = projectiles, .shooting_ctx = shooting_ctx, .columns_remaining = columns_remaining };
    }

    pub fn render(self: *AlienHorde) void {
        for (self.aliens.items) |*alien| {
            if (alien.living_status != utils.LivingStatus.Dead) {
                alien.render();
            }
        }

        for (self.projectiles.items) |*projectile| {
            if (projectile.living_status == utils.LivingStatus.Alive) {
                projectile.render();
            }
        }
    }

    pub fn update(self: *AlienHorde) !void {
        const current_alien = &self.aliens.items[self.ctx.counter];

        if (current_alien.living_status == utils.LivingStatus.Dead) {
            self.ctx.counter += 1;
            return;
        }

        if (self.ctx.counter < 11 or self.aliens.items[self.ctx.counter - 11].living_status == utils.LivingStatus.Dead) {
            if (self.shooting_ctx.counter == self.shooting_ctx.shooter) {
                try self.projectiles.append(Projectile.init(utils.addVec(&current_alien.position, &rl.Vector2.init((Alien.sprite_size.width / 2), 0)), utils.Direction.Down));
            }

            self.shooting_ctx.counter += 1;
        }

        current_alien.update(self.ctx.current_direction);

        if (self.ctx.current_direction != utils.Direction.Down and utils.reached_horizontal_boundary(current_alien.position)) {
            self.ctx.next_direction = utils.Direction.Down;
        }

        if (self.ctx.counter == self.aliens.items.len - 1) {
            if (self.ctx.next_direction == utils.Direction.Down) {
                self.ctx.next_direction = self.ctx.current_direction.reverse();
                self.ctx.current_direction = utils.Direction.Down;
            } else {
                self.ctx.current_direction = self.ctx.next_direction orelse self.ctx.current_direction;
                self.ctx.next_direction = null;
            }

            self.ctx.counter = 0;

            self.shooting_ctx.shooter = rl.getRandomValue(0, self.columns_remaining - 1);
            self.shooting_ctx.counter = 0;
        } else {
            self.ctx.counter += 1;
        }

        for (self.projectiles.items) |*projectile| {
            if (projectile.living_status == utils.LivingStatus.Alive) {
                projectile.update();
            }
        }
    }

    pub fn deinit(self: *AlienHorde) void {
        self.aliens.deinit();
        self.projectiles.deinit();
    }
};
