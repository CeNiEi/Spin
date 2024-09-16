const rl = @import("raylib");
const Ship = @import("ship.zig").Ship;
const AlienHorde = @import("aliens.zig").AlienHorde;
const utils = @import("utils.zig");
const std = @import("std");

pub const GameState = struct {
    ship: Ship,
    alien_horde: AlienHorde,

    pub fn init(alloc: std.mem.Allocator) !GameState {
        const ship_starting_position = rl.Vector2.init(
            utils.SCREEN_WIDTH / 2,
            utils.SCREEN_HEIGHT * 0.9,
        );

        const ship = Ship.init(ship_starting_position, alloc);
        const alien_horde = try AlienHorde.init(alloc);

        return .{ .ship = ship, .alien_horde = alien_horde };
    }

    pub fn render(self: *GameState) void {
        self.ship.render();
        self.alien_horde.render();
    }

    pub fn processInput(self: *GameState) void {
        if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            self.ship.moving_status = utils.MovingStatus{ .Moving = utils.Direction.Left };
        } else if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            self.ship.moving_status = utils.MovingStatus{ .Moving = utils.Direction.Right };
        } else if (rl.isKeyPressed(rl.KeyboardKey.key_space) and self.ship.shooting_status == utils.ShootingStatus.NotShooting) {
            self.ship.shooting_status = utils.ShootingStatus.Shooting;
        }
    }

    pub fn update(self: *GameState) !void {
        try self.ship.update();
        try self.alien_horde.update();

        self.collisionDetector();
    }

    pub fn collisionDetector(self: *GameState) void {
        for (self.ship.projectiles.items) |*projectile| {
            if (projectile.living_status == utils.LivingStatus.Dead) {
                continue;
            }

            for (self.alien_horde.aliens.items, 0..) |*alien, i| {
                if (alien.living_status == utils.LivingStatus.Alive and utils.closeEnough(&alien.position, &projectile.position)) {
                    alien.living_status = utils.LivingStatus{ .Dying = 0 };
                    projectile.living_status = utils.LivingStatus.Dead;

                    if (i / 11 == 4) {
                        self.alien_horde.columns_remaining -= 1;
                    }
                }
            }

            if (projectile.living_status == utils.LivingStatus.Dead) {
                continue;
            }

            for (self.alien_horde.projectiles.items) |*alien_projectile| {
                if (alien_projectile.living_status == utils.LivingStatus.Alive and utils.closeEnough(&alien_projectile.position, &projectile.position)) {
                    alien_projectile.living_status = utils.LivingStatus.Dead;
                    projectile.living_status = utils.LivingStatus.Dead;
                }
            }
        }
    }

    pub fn deinit(self: *GameState) void {
        self.alien_horde.deinit();
        self.ship.deinit();
    }
};
