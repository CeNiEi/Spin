const rl = @import("raylib");
const std = @import("std");
const GameState = @import("state.zig").GameState;
const utils = @import("utils.zig");

//
// const Bunker = struct { position: rl.Vector2 };
//
// const Projectile = struct {
//     position: rl.Vector2,
//     speed: f32,
//     direction: Direction,
//     texture: rl.Texture2D,
//     animation_frame: u32,
//     status: Status,
//
//     pub fn init(position: rl.Vector2, speed: f32, direction: Direction) Projectile {
//         const texture = rl.loadTexture("/Users/tushar/Meditations/SpaceInvaders/assets/Sprite-0004.png");
//         return Projectile{
//             .position = position,
//             .speed = speed,
//             .direction = direction,
//             .texture = texture,
//             .animation_frame = 0,
//             .status = Status.Alive,
//         };
//     }
//
//     pub fn draw(self: *const Projectile) void {
//         const roi = rl.Rectangle.init(@as(f32, @floatFromInt(self.animation_frame)) * 32, 0, 32, 32);
//         rl.drawTextureRec(self.texture, roi, self.position, rl.Color.green);
//     }
//
//     pub fn move(self: *Projectile, direction: Direction) void {
//         switch (direction) {
//             Direction.Up => self.position.y -= self.speed,
//             Direction.Down => self.position.y += self.speed,
//             else => unreachable,
//         }
//
//         self.direction = direction;
//     }
//
//     pub fn tick(self: *Projectile, frames_passed: u32) void {
//         self.animation_frame = (frames_passed / 5) % 5;
//     }
// };
//
// const Status = enum { Alive, Dead };
//
// const Alien = struct {
//     position: rl.Vector2,
//     texture: rl.Texture2D,
//     animation_frame: u32,
//     status: Status,
//
//     pub fn init(
//         position: rl.Vector2,
//     ) Alien {
//         const texture = rl.loadTexture("/Users/tushar/Meditations/SpaceInvaders/assets/Sprite-0001.png");
//         return Alien{
//             .position = position,
//             .texture = texture,
//             .animation_frame = 0,
//             .status = Status.Alive,
//         };
//     }
//
//     pub fn draw(self: *const Alien) void {
//         const roi = rl.Rectangle.init(@as(f32, @floatFromInt(self.animation_frame)) * 32, 0, 32, 32);
//         rl.drawTextureRec(self.texture, roi, self.position, rl.Color.sky_blue);
//     }
//
//     pub fn move(self: *Alien, direction: Direction, speed: f32, time: u64) void {
//         switch (direction) {
//             Direction.Right => self.position.x +=
//                 speed * @as(f32, @floatFromInt(time)) / @as(f32, @floatFromInt(std.time.ns_per_s)),
//             Direction.Left => self.position.x -=
//                 speed * @as(f32, @floatFromInt(time)) / @as(f32, @floatFromInt(std.time.ns_per_s)),
//             Direction.Down => self.position.y += speed,
//             else => unreachable,
//         }
//     }
//
//     pub fn tick(self: *Alien, frames_passed: u32) void {
//         self.animation_frame = (frames_passed / 10) % 10;
//     }
// };
//
// const AlienHorde = struct {
//     aliens: std.ArrayList(Alien),
//     projectiles: std.ArrayList(Projectile),
//     direction: Direction,
//     speed: f32,
//     tick_rate: u32,
//
//     pub fn init(alloc: std.mem.Allocator) !AlienHorde {
//         var aliens = std.ArrayList(Alien).init(alloc);
//         const projectiles = std.ArrayList(Projectile).init(alloc);
//
//         for (0..5) |row| {
//             for (0..11) |col| {
//                 try aliens
//                     .append(Alien.init(rl.Vector2.init(48 * @as(f32, @floatFromInt(col)) + (@as(f32, @floatFromInt(rl.getScreenWidth())) / 10), 32 * @as(f32, @floatFromInt(row)) + @as(f32, @floatFromInt(rl.getScreenHeight())) / 10)));
//             }
//         }
//
//         return .{ .aliens = aliens, .projectiles = projectiles, .direction = Direction.Right, .speed = 50, .tick_rate = 10 };
//     }
//
//     pub fn draw(self: *AlienHorde) void {
//         for (self.aliens.items) |alien| {
//             if (alien.status == Status.Alive) {
//                 alien.draw();
//             }
//         }
//     }
//
//     pub fn tick(self: *AlienHorde) void {
//         const game_state: *GameState = @fieldParentPtr("alien_horde", self);
//
//         for (self.aliens.items) |*alien| {
//             if (alien.status == Status.Alive) {
//                 alien.tick(game_state.frames_passed);
//             }
//         }
//     }
//
//     pub fn drop(self: *AlienHorde) void {
//         self.aliens.deinit();
//         self.projectiles.deinit();
//     }
//
//     pub fn move(self: *AlienHorde, time: u64) void {
//         const game_state: *GameState = @fieldParentPtr("alien_horde", self);
//         for (self.aliens.items, 0..) |*alien, i| {
//             if (i / 11 == (game_state.frames_passed / self.tick_rate) % 5) {
//                 alien.move(self.direction, self.speed, time);
//             }
//         }
//     }
//
//     pub fn turn(self: *AlienHorde) void {
//         const game_state: *GameState = @fieldParentPtr("alien_horde", self);
//
//         for (self.aliens.items) |*alien| {
//             alien.move(Direction.Down, 20, game_state.time_elapsed_since_last_frame);
//         }
//
//         turn_direction(&self.direction);
//     }
// };
//
// const Ship = struct {
//     texture: rl.Texture2D,
//     position: rl.Vector2,
//     speed: f32,
//     animation_frame: u32,
//     projectiles: std.ArrayList(Projectile),
//
//     pub fn init(position: rl.Vector2, speed: f32, alloc: std.mem.Allocator) Ship {
//         const texture = rl.loadTexture("/Users/tushar/Meditations/SpaceInvaders/assets/Sprite-0003.png");
//         const projectiles = std.ArrayList(Projectile).init(alloc);
//         return Ship{
//             .position = position,
//             .texture = texture,
//             .speed = speed,
//             .animation_frame = 0,
//             .projectiles = projectiles,
//         };
//     }
//
//     pub fn draw(self: *const Ship) void {
//         const roi = rl.Rectangle.init(@as(f32, @floatFromInt(self.animation_frame)) * 32, 0, 32, 32);
//
//         rl.drawTextureRec(self.texture, roi, self.position, rl.Color.red);
//
//         for (self.projectiles.items) |projectile| {
//             if (projectile.status == Status.Alive) {
//                 projectile.draw();
//             }
//         }
//     }
//
//     pub fn move(self: *Ship, direction: Direction, time: u64) void {
//         switch (direction) {
//             Direction.Right => self.position.x += (self.speed * @as(f32, @floatFromInt(time)) / @as(f32, @floatFromInt(std.time.ns_per_s))),
//             Direction.Left => self.position.x -= (self.speed * @as(f32, @floatFromInt(time)) / @as(f32, @floatFromInt(std.time.ns_per_s))),
//             else => unreachable,
//         }
//     }
//
//     pub fn shoot(self: *Ship) !void {
//         try self.projectiles.append(Projectile.init(self.position, self.speed, Direction.Up));
//     }
//
//     pub fn drop(self: *Ship) void {
//         self.projectiles.deinit();
//     }
//
//     pub fn tick(self: *Ship) void {
//         const game_state: *GameState = @fieldParentPtr("ship", self);
//
//         self.animation_frame = (game_state.frames_passed / 10) % 10;
//
//         for (self.projectiles.items) |*projectile| {
//             if (projectile.status == Status.Alive) {
//                 projectile.tick(game_state.frames_passed);
//             }
//         }
//     }
// };
//
// const Direction = enum { Up, Down, Right, Left };
//
// fn move_projectiles(projectiles: *std.ArrayList(Projectile), time: u64) void {
//     for (projectiles.items) |*projectile| {
//         projectile.position.y -= (projectile.speed * @as(f32, @floatFromInt(time)) / @as(f32, @floatFromInt(std.time.ns_per_s)));
//         if (projectile.position.y <= @as(f32, @floatFromInt(rl.getScreenHeight())) / 20) {
//             projectile.status = Status.Dead;
//         }
//     }
// }
//
// fn close_enough(a: rl.Vector2, b: rl.Vector2, tolerance: rl.Vector2) bool {
//     const dist_x = a.x - b.x;
//     const dist_y = a.y - b.y;
//
//     return @abs(dist_x) <= tolerance.x and @abs(dist_y) <= tolerance.y;
// }
//
// fn turn_direction(direction: *Direction) void {
//     if (direction.* == Direction.Right) {
//         direction.* = Direction.Left;
//     } else if (direction.* == Direction.Left) {
//         direction.* = Direction.Right;
//     }
// }
//
// fn collisionDetector(alien_horde: *AlienHorde, ship_projectiles: *std.ArrayList(Projectile)) void {
//     for (alien_horde.aliens.items) |*alien| {
//         if (alien.status == Status.Dead) {
//             continue;
//         }
//
//         if (alien.position.x < (@as(f32, @floatFromInt(rl.getScreenWidth())) / 10) or alien.position.x > (@as(f32, @floatFromInt(rl.getScreenWidth())) - @as(f32, @floatFromInt(rl.getScreenWidth())) / 10)) {
//             alien_horde.turn();
//         }
//
//         for (ship_projectiles.items) |*projectile| {
//             if (projectile.status == Status.Dead) {
//                 continue;
//             }
//
//             if (close_enough(projectile.position, alien.position, rl.Vector2.init(
//                 16,
//                 8,
//             ))) {
//                 alien.status = Status.Dead;
//                 projectile.status = Status.Dead;
//                 alien_horde.speed += 5;
//             }
//         }
//     }
// }
//
// const GameState = struct {
//     lives_remaining: u32,
//     score: u32,
//     ship: Ship,
//     alien_horde: AlienHorde,
//     frames_passed: u32,
//     time_elapsed_since_last_frame: u64,
//
//     pub fn init(alloc: std.mem.Allocator) !GameState {
//         const ship = Ship.init(rl.Vector2.init(@as(f32, @floatFromInt(rl.getScreenWidth())) / 2, 300), 100, alloc);
//         const alien_horde = try AlienHorde.init(alloc);
//
//         return GameState{ .lives_remaining = 3, .score = 0, .ship = ship, .alien_horde = alien_horde, .frames_passed = 0, .time_elapsed_since_last_frame = 0 };
//     }
//
//     // pub fn render() void {}
//     //
//     // pub fn update() void {
//     //
//     // }
//     //
//     // pub fn processInput(self: *GameState) void {
//     //     if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
//     //     } else if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
//     //     } else if (rl.isKeyDown(rl.KeyboardKey.key_space)) {
//     //     }
//     // }
//
//     pub fn draw(self: *GameState) void {
//         self.ship.draw();
//         self.alien_horde.draw();
//     }
//
//     pub fn poll(self: *GameState) !void {
//         self.frames_passed += 1;
//
//         self.alien_horde.tick();
//         self.ship.tick();
//
//         if (rl.isKeyDown(rl.KeyboardKey.key_h)) {
//             self.ship.move(Direction.Left, self.time_elapsed_since_last_frame);
//         } else if (rl.isKeyDown(rl.KeyboardKey.key_l)) {
//             self.ship.move(Direction.Right, self.time_elapsed_since_last_frame);
//         } else if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
//             try self.ship.shoot();
//         }
//     }
//
//     pub fn run(self: *GameState) void {
//         move_projectiles(&self.ship.projectiles, self.time_elapsed_since_last_frame);
//         collisionDetector(&self.alien_horde, &self.ship.projectiles);
//
//         self.alien_horde.move(self.time_elapsed_since_last_frame);
//     }
//
//     pub fn drop(self: *GameState) void {
//         self.alien_horde.drop();
//         self.ship.drop();
//     }
// };
//

pub fn main() !void {
    rl.initWindow(utils.SCREEN_WIDTH, utils.SCREEN_HEIGHT, "SpaceInvaders");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var game_state = try GameState.init(alloc);
    defer game_state.deinit();

    const DELTA = 10000000;

    var timer = try std.time.Timer.start();
    var lag: u64 = 0;

    var previous_time = timer.read();

    while (!rl.windowShouldClose()) {
        const current_time = timer.read();

        lag += current_time - previous_time;
        previous_time = current_time;

        game_state.processInput();

        while (lag >= DELTA) {
            try game_state.update();
            lag -= DELTA;
        }

        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);

        game_state.render();

        rl.endDrawing();
        // std.debug.print("current fps: {}\n", .{rl.getFPS()});
    }

    rl.closeWindow();
}
