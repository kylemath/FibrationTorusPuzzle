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
major_radius = 38;
// Oval cross-section: width (radial, along torus path) and height (perpendicular to wrist)
oval_width = 7;
oval_height = 14;
// Clearance between the rings (0.3-0.5 for FDM, 0.15-0.25 for SLA)
gap = 0.4;
// S-curve amplitude: fraction of wedge half-width (0 = no S, 1 = full swing)
s_amp = 0.23;
// Fillet radius to soften sharp edges where S meets the body (0 = sharp)
edge_fillet = 1.2;

/* [Quality] */
// Segments around the torus path (more = smoother but slower)
segments = 512;
// Circle facet count
$fn = 128;

/* [Export] */
// 0 = all rings, 1 = ring A, 2 = ring B, 3 = ring C, 4 = ring D
show_ring = 0;
// Cut in half to show cross-section (C-shape for fitting check)
show_cross_section = false;


// --- Yin-yang slice (1 of 4 pieces) ---
// 90-degree wedge with sinusoidal S-curve edges.
// s_amp: fraction of wedge half-width used by the S swing (0 = straight, 1 = full swing).
module yin_yang_slice(r, amp) {
    A  = 90;
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

// --- One ring of the linked 4-piece set ---
// Sweeps a yin-yang slice around the torus, twisting it by one
// full turn so the cross-section completes a 360° helix.
// ow, oh: oval width (radial) and height (perpendicular to wrist) of the tube cross-section.
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
                                    yin_yang_slice(r, amp);
    }
}

// --- Render ---
module all_rings() {
    if (show_ring == 0 || show_ring == 1)
        color("YellowGreen")
            yin_yang_ring(major_radius, oval_width, oval_height, gap, segments, 0, s_amp, edge_fillet);

    if (show_ring == 0 || show_ring == 2)
        color("Orchid")
            yin_yang_ring(major_radius, oval_width, oval_height, gap, segments, 90, s_amp, edge_fillet);

    if (show_ring == 0 || show_ring == 3)
        color("SkyBlue")
            yin_yang_ring(major_radius, oval_width, oval_height, gap, segments, 180, s_amp, edge_fillet);

    if (show_ring == 0 || show_ring == 4)
        color("Coral")
            yin_yang_ring(major_radius, oval_width, oval_height, gap, segments, 270, s_amp, edge_fillet);
}

if (show_cross_section)
    difference() {
        all_rings();
        // Remove left half to expose cross-section at cut plane
        translate([-major_radius - oval_height - 10, 0, 0])
            cube([major_radius * 2 + oval_height * 2 + 20, major_radius * 2 + 20, major_radius * 2 + 20], center = true);
    }
else
    all_rings();
