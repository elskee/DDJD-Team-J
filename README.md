# DDJD-Team-J
Repository for the DDJD course 
Project structure
game_manager.gd (autoload) - Global game state
- Tracks sleepiness (0-100), eyes closed/open, flashlight, death state
- Emits signals for state changes
- The man_active flag lets monsters coordinate
tv_controller.gd (replaces TV.gd on the mesh) - TV with 3 states
- OFF - invisible, silent
- SAFE - normal screen (safeTV.tres), helps sleepiness +1/rate, corruption timer counts up
- CORRUPTED - flickers between safe/danger materials every 0.15s, can't turn on again for 3s after turning off (reset mechanic)
- Jumpscares if corrupted for 5s
man_monster.gd - The coat-on-hanger monster
- Appears after 15-40s random delay
- Suspicion starts at 30%, increases when eyes open (+10/s) or flashlight on (+25/s), decreases when eyes closed (-15/s)
- Turns off TV after 5s of presence
- Jumpscares at 100% suspicion, leaves at 0%
- Blocks ghost while present
ghost_monster.gd - Sleep paralysis ghost
- Appears after 30-60s (blocked if MAN is active)
- Audio-mute hook ready (needs sound assets)
- Jumpscares after 8s of presence
- Forced to leave if MAN appears
main.gd - Coordinator
- Creates monsters at runtime, wires all signals
- Space (hold) = close eyes → sleepiness +2/s (+3/s with safe TV)
- F (toggle) = flashlight (angers MAN)
- T (toggle) = TV on/off
- Sleepiness decays at -1/s with eyes open
- Win at 100% sleepiness, lose on any jumpscare
Controls added: toggleTV mapped to T key