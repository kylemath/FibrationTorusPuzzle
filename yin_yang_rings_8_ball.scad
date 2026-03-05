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
major_radius = 10;
// Oval cross-section: width (radial, along torus path) and height (perpendicular to wrist)
oval_width = 10;
oval_height = 25;
// Clearance between the rings
gap = 0.4;
// S-curve amplitude: fraction of wedge half-width (0 = no S, 1 = full swing)
s_amp = 0.7;
// Fillet radius to soften sharp edges where S meets the body (0 = sharp)
edge_fillet = 0;

/* [Quality] */
// Segments around the torus path (more = smoother but slower)
segments = 256;
// Circle facet count
$fn = 96;

/* [Export] */
// 0 = all rings, 1..8 = individual rings
show_ring = 0;
// Cut in half to show cross-section
show_cross_section = false;

// --- Yin-yang eighth (1 of 8 pieces) ---
// 45-degree wedge whose radial edges follow a smooth sinusoidal S-curve.
module yin_yang_eighth(r, amp) {
    A  = 45;
    s  = amp * A / 2;
    N  = 64;
    aN = max(8, round(N * A / 180));

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

// --- One ring of the linked 8-piece set ---
// ow, oh: oval width (radial) and height of the tube cross-section.
module yin_yang_ring(R, ow, oh, g, n, phase, amp, fillet) {
    r = max(ow, oh) / 2;
    sx = ow / (2 * r);
    sy = oh / (2 * r);
    step = 360 / n;
    for (i = [0 : n - 1]) {
        a = i * step;
        rotate([0, 0, a])
            rotate_extrude(angle = step + 0.1)
                translate([R, 0])
                    scale([sx, sy])
                        rotate([0, 0, a + phase])
                            offset(r = -(g / 2 + fillet))
                                offset(r = fillet)
                                    yin_yang_eighth(r, amp);
    }
}

// --- Render ---
colors = [
    "Red", "DarkOrange", "Gold", "LimeGreen", 
    "MediumTurquoise", "DodgerBlue", "DarkOrchid", "DeepPink"
];

module all_rings() {
    for (i = [0 : 7]) {
        if (show_ring == 0 || show_ring == (i + 1)) {
            color(colors[i])
                yin_yang_ring(major_radius, oval_width, oval_height, gap, segments, i * 45, s_amp, edge_fillet);
        }
    }
}

if (show_cross_section)
    difference() {
        all_rings();
        translate([-major_radius - oval_height - 10, 0, 0])
            cube([major_radius * 2 + oval_height * 2 + 20, major_radius * 2 + 20, major_radius * 2 + 20], center = true);
    }
else
    all_rings();
