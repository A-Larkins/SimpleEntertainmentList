from PIL import Image, ImageDraw
import math, os

SIZE = 1024
paper = (246, 243, 236, 255)
paper_shadow = (223, 216, 198, 255)
ink = (36, 31, 26, 255)
accent = (138, 106, 75, 255)
accent_light = (196, 160, 118, 255)

def squircle_mask(size, radius_ratio=0.225):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    r = int(size * radius_ratio)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=255)
    return mask

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

# background with soft vertical gradient
bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
grad = Image.new("L", (1, SIZE))
for y in range(SIZE):
    t = y / SIZE
    grad.putpixel((0, y), int(255 * (1 - 0.10 * t)))
grad = grad.resize((SIZE, SIZE))
base = Image.new("RGBA", (SIZE, SIZE), paper)
shadow_layer = Image.new("RGBA", (SIZE, SIZE), paper_shadow)
bg = Image.composite(base, shadow_layer, grad)

mask = squircle_mask(SIZE)
img.paste(bg, (0, 0), mask)

draw = ImageDraw.Draw(img)

# Bookmark ribbon glyph
bw = SIZE * 0.34
bh = SIZE * 0.52
cx = SIZE / 2
top = SIZE * 0.24
left = cx - bw / 2
right = cx + bw / 2
bottom = top + bh
notch = SIZE * 0.10

ribbon = [
    (left, top),
    (right, top),
    (right, bottom),
    (cx, bottom - notch),
    (left, bottom),
]
draw.polygon(ribbon, fill=ink)

# horizontal "pages" lines near the top of the ribbon
line_w = bw * 0.56
line_x0 = cx - line_w / 2
line_x1 = cx + line_w / 2
for i, ly in enumerate([top + bh * 0.16, top + bh * 0.26]):
    draw.line([(line_x0, ly), (line_x1, ly)], fill=paper, width=int(SIZE * 0.014))

# play triangle cut into the lower half of the ribbon, in accent gold
pw = bw * 0.34
ph = bh * 0.26
pcx = cx
pcy = top + bh * 0.62
tri = [
    (pcx - pw * 0.35, pcy - ph / 2),
    (pcx - pw * 0.35, pcy + ph / 2),
    (pcx + pw * 0.55, pcy),
]
draw.polygon(tri, fill=accent_light)

img.save(os.path.join(os.path.dirname(__file__), "icon_1024.png"))
print("saved")
