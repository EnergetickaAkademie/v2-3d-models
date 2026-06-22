$fn = 60;

render_mode = 2; // [0:Bottom Plate, 1:Top Hood, 2:Both (Exploded)]

led1_pos = [45.85, 131.06];
led2_pos = [103.00, 131.06];
led3_pos = [45.85, 114.05];
led4_pos = [103.00, 114.05];
enc1_pos = [43.31, 82.30];
enc2_pos = [101.98, 82.30];
dsub1_pos = [26.16, 90.93];
dsub2_pos = [122.68, 90.93];
h1 = [33.15, 77.98];
h2 = [79.25, 90.93];
h3 = [67.69, 117.60];
h4 = [113.67, 77.85];
s1 = [35.15, 132];
s2 = [110, 132];

disp_w = 51.5;
disp_h = 20;
bar_w = 26.5;
bar_h = 11.5;
enc_hole_d = 7.5;

case_min_x = 16;
case_max_x = 134;
case_min_y = 70;
case_max_y = 143;

case_width = case_max_x - case_min_x;
case_length = case_max_y - case_min_y;

// Restored to your original dimensions
wall_thickness = 2;

base_thickness = 2.0;
dsub_body_thickness = 12.5;
dsub_clearance_to_floor = 1.0;

standoff_h = dsub_body_thickness + dsub_clearance_to_floor - 0.5;
standoff_minus_h = 1.0;
pcb_thickness = 1.6;

dsub_center_offset = -(dsub_body_thickness / 2);
dsub_z = base_thickness + standoff_h + dsub_center_offset;

display_height_above_pcb = 6.0;
total_internal_height = base_thickness + standoff_h + pcb_thickness + display_height_above_pcb;
fit_tolerance = -0.2;

dsub_bot_tol = 0.0;
dsub_wide_side_up = false;

explode_dist = (render_mode == 2) ? 25 : 0;
dsub_bot_left_oversize = 1.0;
dsub_bot_right_oversize = 2.0;

// --- DETENT SNAP-FIT PARAMETERS ---
hook_w = 10.0;
hook_t = 1.6;
hook_h = 10.0;
hook_protrusion = 1.2; // Snaps 1.2mm into the 2.0mm wall, leaving 0.8mm of solid plastic on the outside

// Positions for the 4 tabs along the Front and Back edges
x1 = case_min_x + (case_width * 0.33);
x2 = case_min_x + (case_width * 0.67);

module dsub(sc,sz,dp){
    $fn=64;
    cs=(sz/2)-2.6;
    cs2=(sz/2)-4.095;
    scale([sc,sc,sc]) hull(){
        translate([0,-cs,0]) cylinder(r=2.6,h=10);
        translate([0,cs,0]) cylinder(r=2.6,h=10);
        translate([3.28,-cs2,0]) cylinder(r=2.6,h=10);
        translate([3.28,cs2,0]) cylinder(r=2.6,h=10);
    }
}

module centered_dsub() {
    translate([-1.66, 0, 0])
    dsub(sc=1.2, sz=17.04, dp=10);
}

module oriented_dsub(flip_orientation) {
    translate([0, 0, -5])
    rotate([0, 0, flip_orientation ? 180 : 0])
    centered_dsub();
}

// Generates the sloped detent wedge (sloped top for insertion, sloped bottom for screwdriver prying)
module yz_detent_wedge(dir) {
    hull() {
        translate([-hook_w/2, 0, 0]) cube([hook_w, 0.01, 5]);
        translate([-hook_w/2, dir * hook_protrusion, 2]) cube([hook_w, 0.01, 0.01]);
    }
}

module vertical_detent_hook(is_front) {
    if (is_front) {
        translate([-hook_w/2, 0, 0]) cube([hook_w, hook_t, hook_h]);
        translate([0, 0, hook_h - 5]) yz_detent_wedge(-1);
    } else {
        translate([-hook_w/2, -hook_t, 0]) cube([hook_w, hook_t, hook_h]);
        translate([0, 0, hook_h - 5]) yz_detent_wedge(1);
    }
}

// Cuts the hidden inlets and insertion chamfers out of the top hood
module hood_inlets_and_chamfers() {
    clearance = 0.2;
    for(tx = [x1, x2]) {
        // Front internal pockets
        translate([tx, case_min_y, base_thickness + hook_h - 5])
        hull() {
            translate([-(hook_w+1)/2, 0, -clearance]) cube([hook_w+1, 0.01, 5 + 2*clearance]);
            translate([-(hook_w+1)/2, -hook_protrusion - clearance, 2]) cube([hook_w+1, 0.01, 0.01]);
        }
        // Front entry chamfer (guides the hooks inward as the hood slides down)
        translate([tx, case_min_y, 0])
        hull() {
            translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
            translate([-(hook_w+1)/2, -hook_protrusion - 0.2, -0.1]) cube([hook_w+1, 0.01, 0.1]);
            translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
        }

        // Back internal pockets
        translate([tx, case_max_y, base_thickness + hook_h - 5])
        hull() {
            translate([-(hook_w+1)/2, 0, -clearance]) cube([hook_w+1, 0.01, 5 + 2*clearance]);
            translate([-(hook_w+1)/2, hook_protrusion + clearance, 2]) cube([hook_w+1, 0.01, 0.01]);
        }
        // Back entry chamfer
        translate([tx, case_max_y, 0])
        hull() {
            translate([-(hook_w+1)/2, 0, -0.1]) cube([hook_w+1, 0.01, 0.1]);
            translate([-(hook_w+1)/2, hook_protrusion + 0.2, -0.1]) cube([hook_w+1, 0.01, 0.1]);
            translate([-(hook_w+1)/2, 0, hook_protrusion + 0.2]) cube([hook_w+1, 0.01, 0.1]);
        }
    }
}

module top_hood() {
    translate([0, 0, explode_dist])
    difference() {
        // Main outer body
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
        cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + wall_thickness]);

        // Inner cavity
        translate([case_min_x, case_min_y, -0.1])
        cube([case_width, case_length, total_internal_height + 0.1]);

        // Subtract the hidden detent inlets and entry chamfers
        hood_inlets_and_chamfers();

        // D-Sub Cutouts
        translate([case_min_x, dsub1_pos[1], dsub_z])
        rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
        translate([case_max_x, dsub2_pos[1], dsub_z])
        rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);

        // U-Slots for D-sub insertion
        translate([case_min_x - wall_thickness - 0.1, dsub1_pos[1] - 17, -0.1])
        cube([wall_thickness + 0.2, 34, dsub_z + 0.1]);
        translate([case_max_x - 0.1, dsub2_pos[1] - 17, -0.1])
        cube([wall_thickness + 0.2, 34, dsub_z + 0.1]);

        // Roof Cutouts
        roof_z = total_internal_height;
        translate([led1_pos[0], led1_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
        translate([led2_pos[0], led2_pos[1], roof_z + wall_thickness/2]) cube([disp_w, disp_h, wall_thickness * 3], center=true);
        translate([led3_pos[0], led3_pos[1], roof_z + wall_thickness/2]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
        translate([led4_pos[0], led4_pos[1], roof_z + wall_thickness/2]) cube([bar_w, bar_h, wall_thickness * 3], center=true);
        translate([enc1_pos[0], enc1_pos[1], roof_z]) cylinder(d=enc_hole_d, h=wall_thickness * 3);
        translate([enc2_pos[0], enc2_pos[1], roof_z]) cylinder(d=enc_hole_d, h=wall_thickness * 3);

        // Base seam pry notch (small recess to help get a flathead screwdriver into the bottom seam)
        translate([case_min_x + case_width/2 - 7.5, case_max_y - 0.1, -0.1])
        cube([15, wall_thickness + 0.2, 1.5]);
    }
}

module bottom_plate() {
    union() {
        // Flat access plate
        translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, 0])
        cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, base_thickness]);

        // Upward filler tabs
        difference() {
            union() {
                translate([case_min_x - wall_thickness, dsub1_pos[1] - 17 + fit_tolerance, 0])
                cube([wall_thickness + fit_tolerance + 0.1 + dsub_bot_left_oversize, 34 - 2*fit_tolerance, dsub_z + dsub_bot_tol]);
                translate([case_max_x - fit_tolerance - 0.1 - dsub_bot_right_oversize, dsub2_pos[1] - 17 + fit_tolerance, 0])
                cube([wall_thickness + fit_tolerance + 0.1 + dsub_bot_right_oversize, 34 - 2*fit_tolerance, dsub_z + dsub_bot_tol]);
            }
            translate([case_min_x, dsub1_pos[1], dsub_z]) rotate([0, -90, 0]) oriented_dsub(dsub_wide_side_up);
            translate([case_max_x, dsub2_pos[1], dsub_z]) rotate([0, 90, 0]) oriented_dsub(!dsub_wide_side_up);
        }

        // Add the vertical detent hooks to the edge of the plate
        for (tx = [x1, x2]) {
            translate([tx, case_min_y + fit_tolerance, base_thickness])
            vertical_detent_hook(true);

            translate([tx, case_max_y - fit_tolerance, base_thickness])
            vertical_detent_hook(false);
        }

        standoff(h1);
        standoff(h2);
        standoff(h3);
        standoff(h4);
        standoff(s1);
        standoff(s2);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=6, h=standoff_h-standoff_minus_h);
        translate([0,0,1]) cylinder(d=2.2, h=standoff_h);
    }
}

// --- Render Logic ---
if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_plate();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_hood();
}
