/*
 * 8-Piece Interlocking Rings
 *
 * A torus divided into 8 linked rings by twisted S-curves.
 * Each ring sweeps around the torus, twisting 360 degrees, weaving
 * through the others in an 8-way Hopf link.
 *
 * RENDERING: F5 for preview, F6 for full render.
 */

/* [Dimensions] */
// Distance from torus center to tube center
major_radius = 15;
// Yin-yang cross-section radius (tube radius)
minor_radius = 7;
// Clearance between the rings
gap = 0.4;

// Number of segments
num_segments = 6;

/* [Quality] */
// Segments around the torus path (more = smoother but slower)
segments = 256;
// Circle facet count
$fn = 96;
 
/* [Export] */
// 0 = all rings, 1..6 = individual rings
show_ring = 0;

/* [S-curve] */
// Fraction of available wedge width used by each S-curve bulge (0-1)
s_amp = .7;

// --- Yin-yang sixth (1 of 6 pieces) ---
// 45-degree wedge whose radial edges follow a smooth sinusoidal S-curve.
// The S amplitude scales with the wedge width at each radius, so the
// curve is proportionally balanced from center to rim.
module yin_yang_sixth(r) {
    A  = 360 / num_segments;
    s  = s_amp * A / 2;
    N  = 64;
    aN = max(num_segments, round(N * A / 180));

    lower = [for (i = [0 : N])
        let(rho = r * i / N,
            a   = s * sin(360 * i / N))
        [rho * cos(a), rho * sin(a)]];

    arc = [for (i = [1 : aN - 1])
        let(a = A * i / aN)
        [r * cos(a), r * sin(a)]];

    upper = [for (i = [N : -1 : 1])
        let(rho = r * i / N,
            a   = A + s * sin(360 * i / N))
        [rho * cos(a), rho * sin(a)]];

    intersection() {
        circle(r = r);
        polygon(concat(lower, arc, upper));
    }
}

// --- One ring of the linked 6-piece set ---
module yin_yang_ring(R, r, g, n, phase) {
    step = 360 / n;
    for (i = [0 : n - 1]) {
        a = i * step;
        rotate([0, 0, a])
            rotate_extrude(angle = step + 0.1)
                translate([R, 0])
                    rotate([0, 0, a + phase])
                        offset(r = -g / 2)
                            yin_yang_sixth(r);
    }
}

// --- Render ---
colors = [
    "Red", "DarkOrange", "Gold", "LimeGreen", 
    "MediumTurquoise", "DodgerBlue", "DarkOrchid", "DeepPink"
];

for (i = [0 : num_segments - 1]) {
    if (show_ring == 0 || show_ring == (i + 1)) {
        color(colors[i])
            yin_yang_ring(major_radius, minor_radius, gap, segments, i * (360 / num_segments));
    }
}
