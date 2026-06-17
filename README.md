# s_needs

A lightweight, server-authoritative hunger and thirst system with persistence and
StateBag sync for zero-latency HUD display.

## Function

s_needs decays a player's hunger and thirst on a timer, applies gentle damage when either
value reaches zero, and persists both values through s_core's character metadata so they
survive a relog. The current values are pushed into a StateBag so the HUD (or any other
resource) can read them instantly with no network round-trip.

## Key Features

- Single shared decay thread ticking all online players together rather than one thread
  per player
- Damage-at-zero is floored so it can never outright kill a player from neglect alone,
  only ever bring them to critical health
- StateBag sync (`LocalPlayer.state['saga:needs']`) for instant, zero-latency HUD reads
- Persisted through s_core character metadata, fully restored on character load
- Clean export surface: `ModifyNeed`, `SetNeed`, `GetNeed` for any other resource
  (food items, drink items, the wyrd engine, etc.) to hook into

## Security Updates

- **Test and debug commands properly admin-gated.** `/eat`, `/drink`, and the new
  `/setneed` admin command all check `IsAdmin` before doing anything, rather than being
  exposed to all players during development.
- Need values are only ever modified server-side; clients display the StateBag value
  but never write to it directly.

## Dependencies

`s_core` (character metadata persistence, admin checks), `s_lib` (cron for the decay
tick).
