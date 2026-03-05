/*
 * Yin-Yang Interlocking Rings
 *
 * A torus divided into two linked rings (Hopf link) by a twisted
 * yin-yang S-curve. Each ring includes the traditional dot—a small
 * circular feature connected by a thin bridge to the main body—
 * that forms where the ring pinches through the opposite ring's
 * widest lobe. The two pieces cannot be separated without breaking.
 *
 * RENDERING: F5 for preview, F6 for full render (may take 1-3 min).
 * PRINTING:  Set show_ring = 1 or 2 to export individual STLs,
 *            or 0 for print-in-place linked pair.
 */

/* [Dimensions] */
major_radius = 30;    // Torus center to tube center
minor_radius = 14;    // Yin-yang cross-section radius
gap = 0.4;            // Clearance between rings (mm)
dot_radius = 2.5;     // Radius of the yin-yang dots
bridge_width = 1.0;   // Bridge connecting dot to main body

/* [Quality] */
segments = 72;        // Segments around torus (72-144)
$fn = 48;

/* [Export] */
show_ring = 1;        // 0 = both, 1 = ring A, 2 = ring B


// One yin-yang half with its dot and connecting bridge.
// The complementary half's dot/bridge are cut as voids.
// Rotating 180° yields the other half.
module yang_region(r, dr, bw) {
    difference() {
        union() {
            // Yang teardrop
            difference() {
                union() {
                    intersection() {
                        circle(r = r);
                        translate([-r, -r]) square([r, r * 2]);
                    }
                    translate([0, r / 2]) circle(r = r / 2);
                }
                translate([0, -r / 2]) circle(r = r / 2);
            }
            // Yang dot inside the yin lobe
            translate([0, -r / 2]) circle(r = dr);
            // Bridge from main body to dot
            translate([-r / 2, -r / 2 - bw / 2])
                square([r / 2 - dr, bw]);
        }
        // Void for the yin dot inside the yang lobe
        translate([0, r / 2]) circle(r = dr);
        // Void for the yin bridge
        translate([dr, r / 2 - bw / 2])
            square([r / 2 - dr, bw]);
    }
}

// Sweep the cross-section around the torus with a full 360° twist.
module yin_yang_ring(R, r, dr, bw, g, n, phase) {
    step = 360 / n;
    for (i = [0 : n - 1]) {
        a = i * step;
        rotate([0, 0, a])
            rotate_extrude(angle = step + 0.1)
                translate([R, 0])
                    rotate([0, 0, a + phase])
                        offset(r = -g / 2)
                            yang_region(r, dr, bw);
    }
}

// --- Render ---
if (show_ring != 2)
    color("YellowGreen")
        yin_yang_ring(major_radius, minor_radius, dot_radius,
                      bridge_width, gap, segments, 0);

if (show_ring != 1)
    color("Orchid")
        yin_yang_ring(major_radius, minor_radius, dot_radius,
                      bridge_width, gap, segments, 180);
