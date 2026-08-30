#!/usr/bin/env python3
"""Generate a detailed coffee cup with steam icon for StayAwake."""
from PIL import Image, ImageDraw
import math

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Colors
YELLOW = (255, 214, 10, 255)       # #FFD60A - cup body
DARK_YELLOW = (200, 170, 5, 255)   # darker shade for depth
BROWN = (139, 90, 43, 255)         # coffee liquid
DARK_BROWN = (101, 67, 33, 255)    # coffee shadow
WHITE = (255, 255, 255, 255)       # steam
LIGHT_YELLOW = (255, 240, 150, 255) # cup highlight

cx, cy = SIZE // 2, SIZE // 2 + 40

# --- Saucer (ellipse at bottom) ---
saucer_y = cy + 220
saucer_rx, saucer_ry = 280, 60
draw.ellipse(
    [cx - saucer_rx, saucer_y - saucer_ry, cx + saucer_rx, saucer_y + saucer_ry],
    fill=(200, 200, 200, 255), outline=(160, 160, 160, 255), width=4
)
# Saucer inner ring
draw.ellipse(
    [cx - saucer_rx + 40, saucer_y - saucer_ry + 15, cx + saucer_rx - 40, saucer_y + saucer_ry - 15],
    fill=None, outline=(180, 180, 180, 255), width=3
)

# --- Cup body (rounded rectangle / trapezoid) ---
cup_top = cy - 160
cup_bot = cy + 180
cup_top_half = 200  # half-width at top
cup_bot_half = 160  # half-width at bottom (slightly tapered)

# Cup body - draw as polygon for taper
cup_points = [
    (cx - cup_top_half, cup_top),
    (cx + cup_top_half, cup_top),
    (cx + cup_bot_half, cup_bot),
    (cx - cup_bot_half, cup_bot),
]
draw.polygon(cup_points, fill=YELLOW, outline=DARK_YELLOW, width=4)

# Cup rim (top ellipse)
rim_ry = 30
draw.ellipse(
    [cx - cup_top_half, cup_top - rim_ry, cx + cup_top_half, cup_top + rim_ry],
    fill=LIGHT_YELLOW, outline=DARK_YELLOW, width=4
)

# Cup bottom ellipse
draw.ellipse(
    [cx - cup_bot_half, cup_bot - 20, cx + cup_bot_half, cup_bot + 20],
    fill=DARK_YELLOW, outline=DARK_YELLOW, width=2
)

# --- Handle (right side) ---
handle_cx = cx + cup_top_half + 30
handle_cy = cy + 20
handle_rx, handle_ry = 70, 100

# Draw handle as thick arc
for w in range(16):
    offset = w - 8
    draw.ellipse(
        [handle_cx - handle_rx - offset, handle_cy - handle_ry - offset,
         handle_cx + handle_rx + offset, handle_cy + handle_ry + offset],
        fill=None, outline=YELLOW, width=3
    )
# Cover inner part
draw.ellipse(
    [handle_cx - handle_rx + 12, handle_cy - handle_ry + 12,
     handle_cx + handle_rx - 12, handle_cy + handle_ry - 12],
    fill=(0, 0, 0, 0)
)
# Redraw handle outline cleanly
for w in range(3):
    draw.ellipse(
        [handle_cx - handle_rx - 8 + w, handle_cy - handle_ry - 8 + w,
         handle_cx + handle_rx + 8 - w, handle_cy + handle_ry + 8 - w],
        fill=None, outline=DARK_YELLOW, width=2
    )

# --- Coffee liquid inside cup ---
coffee_top = cup_top + 40
coffee_bot = cup_bot - 30
coffee_top_half = cup_top_half - 20
coffee_bot_half = cup_bot_half - 15

coffee_points = [
    (cx - coffee_top_half, coffee_top),
    (cx + coffee_top_half, coffee_top),
    (cx + coffee_bot_half, coffee_bot),
    (cx - coffee_bot_half, coffee_bot),
]
draw.polygon(coffee_points, fill=BROWN)

# Coffee surface (ellipse)
coffee_surface_ry = 22
draw.ellipse(
    [cx - coffee_top_half, coffee_top - coffee_surface_ry,
     cx + coffee_top_half, coffee_top + coffee_surface_ry],
    fill=DARK_BROWN
)

# --- Steam lines ---
def draw_steam(draw, x, y_start, height, amplitude, phase):
    """Draw a wavy steam line."""
    points = []
    for i in range(0, height, 2):
        t = i / height
        x_off = amplitude * math.sin(t * 4 * math.pi + phase) * (1 - t * 0.5)
        alpha = int(255 * (1 - t) * 0.7)
        points.append((x + x_off, y_start - i))
    
    for i in range(len(points) - 1):
        t = i / len(points)
        alpha = int(255 * (1 - t) * 0.6)
        draw.line([points[i], points[i + 1]], fill=(255, 255, 255, alpha), width=8)

steam_base_y = cup_top - rim_ry - 10
draw_steam(draw, cx - 60, steam_base_y, 280, 25, 0)
draw_steam(draw, cx, steam_base_y, 320, 30, 1.5)
draw_steam(draw, cx + 60, steam_base_y, 260, 22, 3.0)

# --- Highlight on cup ---
highlight_x = cx - 80
highlight_y = cy - 40
for i in range(20):
    alpha = int(80 * (1 - i / 20))
    draw.ellipse(
        [highlight_x - 30 + i, highlight_y - 80 + i * 2,
         highlight_x + 30 - i, highlight_y + 80 - i * 2],
        fill=(255, 255, 255, alpha)
    )

# Save
img.save('/Users/danial/Documents/Default Project/CaffeineBar/Icons/icon_1024.png')
print('Generated icon_1024.png')
