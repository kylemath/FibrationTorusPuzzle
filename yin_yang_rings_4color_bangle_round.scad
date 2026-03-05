/*
 * 4-Piece Interlocking Rings
 *
 * A torus divided into four linked rings by two orthogonal twisted
 * yin-yang S-curves. Each ring sweeps around the torus, twisting
 * 360 degrees, weaving through the others in a 4-way Hopf link.
 *
 * RENDERING: F5 for preview, F6 for full render (30-120s).
 * PRINTING:  Set show_ring = 1, 2, 3, or 4 to export individual STLs,
 *            or 0 for print-in-place linked pieces.
 */

/* [Dimensions] */
// Distance from torus center to tube center
major_radius = 34;
// Yin-yang cross-section radius (tube radius)
minor_radius = 5.75;
// Clearance between the rings (0.3-0.5 for FDM, 0.15-0.25 for SLA)
gap = 0.5;

/* [Quality] */
// Segments around the torus path (more = smoother but slower)
segments = 256;
// Circle facet count
$fn = 96;

/* [Export] */
// 0 = all rings, 1 = ring A, 2 = ring B, 3 = ring C, 4 = ring D
show_ring = 0;


// --- Yin-yang quarter (1 of 4 pieces) ---
// 90-degree wedge with one bulging edge and one indented edge.
module yin_yang_quarter(r) {
    difference() {
        union() {
            intersection() {
                circle(r = r);
                square(r);
            }
            translate([r / 2, 0]) circle(r = r / 2);
        }
        translate([0, r / 2]) circle(r = r / 2);
    }
}

// --- One ring of the linked 4-piece set ---
// Sweeps a yin-yang quarter around the torus, twisting it by one
// full turn so the cross-section completes a 360° helix.
module yin_yang_ring(R, r, g, n, phase) {
    step = 360 / n;
    for (i = [0 : n - 1]) {
        a = i * step;
        rotate([0, 0, a])
            rotate_extrude(angle = step + 0.1)
                translate([R, 0])
                    rotate([0, 0, a + phase])
                        offset(r = -g / 2)
                            yin_yang_quarter(r);
    }
}

// --- Render ---
if (show_ring == 0 || show_ring == 1)
    color("YellowGreen")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 0);

if (show_ring == 0 || show_ring == 2)
    color("Orchid")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 90);

if (show_ring == 0 || show_ring == 3)
    color("SkyBlue")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 180);

if (show_ring == 0 || show_ring == 4)
    color("Coral")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 270);
