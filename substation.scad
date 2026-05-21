$fn = 60;

render_mode = 2; // [0:Bottom Tray, 1:Top Lid, 2:Both (Exploded)]

// --- Board Dimensions ---
board_w = 87.5;
board_h = 52.5;
board_clearance = 2.0;

// --- Extracted Board Coordinates ---
usb_top_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_bot_x = [19.94, 32.64, 45.34, 58.04, 70.74, 83.44];
usb_in_y = 117.35;

h1 = [10.41, 140.21];
h2 = [92.58, 140.34];
h3 = [92.58, 93.98];
h4 = [10.29, 93.85];

// --- Parametric Case Boundaries ---
board_center_x = (h1[0] + h2[0] + h3[0] + h4[0]) / 4;
board_center_y = (h1[1] + h2[1] + h3[1] + h4[1]) / 4;

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

case_min_x = board_center_x - (case_width / 2);
case_max_x = board_center_x + (case_width / 2);
case_min_y = board_center_y - (case_length / 2);
case_max_y = board_center_y + (case_length / 2);

wall_thickness = 1.0;

// --- Z-Axis Hardware Stack (Bottom Up) ---
base_thickness = 2.0;
standoff_h = 4.0;
pcb_thickness = 1.6;

usb_center_above_pcb = 1.6;
usb_z = base_thickness + standoff_h + pcb_thickness + usb_center_above_pcb;

clearance_above_pcb = 12.0;
total_internal_height = standoff_h + pcb_thickness + clearance_above_pcb;

// --- Fit Tolerances & Shapes ---
fit_tolerance = -0.05;
u_slot_w = 11.5;

explode_dist = (render_mode == 2) ? 25 : 0;

usb_chamfer_w1 = 9.5;
usb_chamfer_h1 = 3.5;
usb_chamfer_w2 = 13.0;
usb_chamfer_h2 = 9;


// --- Pill and Chamfer Profiles ---
module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module usb_chamfer(w1, h1, w2, h2, length) {
    union() {
        // Tapered exterior indent
        hull() {
            translate([0, 0, 0]) pill(w1, h1, 0.01);
            translate([0, 0, length]) pill(w2, h2, 0.01);
        }
        // Inner straight clearance to clear the connector body inside the case
        translate([0, 0, -10]) pill(w1, h1, 20);
    }
}

module bottom_tray() {
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
        cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + base_thickness]);

        translate([case_min_x, case_min_y, base_thickness])
        cube([case_width, case_length, total_internal_height + 1]);

        // --- Subtract USB Outlines (Chamfered windows cut directly into walls) ---
        /*for(x = usb_top_x) translate([x, case_max_y, usb_z]) rotate([-90, 0, 0]) usb_chamfer(usb_chamfer_w1, usb_chamfer_h1, usb_chamfer_w2, usb_chamfer_h2, wall_thickness + 0.1);
         *       for(x = usb_bot_x) translate([x, case_min_y, usb_z]) rotate([90, 0, 0]) usb_chamfer(usb_chamfer_w1, usb_chamfer_h1, usb_chamfer_w2, usb_chamfer_h2, wall_thickness + 0.1);
         *
         *       translate([case_min_x, usb_in_y, usb_z]) rotate([90, 0, -90]) usb_chamfer(usb_chamfer_w1, usb_chamfer_h1, usb_chamfer_w2, usb_chamfer_h2, wall_thickness + 0.1);*/


        for(x = usb_top_x) translate([x, case_max_y, usb_z]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        for(x = usb_bot_x) translate([x, case_min_y, usb_z]) rotate([90, 0, 0]) pill(9.5, 3.5, 20);

        translate([case_min_x, usb_in_y, usb_z]) rotate([90, 0, -90]) pill(9.5, 3.5, 20);
    }

    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);
}

module top_lid() {
    translate([0, 0, base_thickness + total_internal_height + explode_dist])
    difference() {
        union() {
            // Flat Roof
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, wall_thickness]);

            // Inner Friction Alignment Lip
            translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, -3])
            difference() {
                cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, 3]);
                translate([wall_thickness, wall_thickness, -1])
                cube([case_width - 2*fit_tolerance - 2*wall_thickness, case_length - 2*fit_tolerance - 2*wall_thickness, 5]);
            }

            // --- INTERNAL CLAMPING PILLARS ---
            // These drop down inside the case to push down on the USB connector bodies
            tab_drop = total_internal_height + base_thickness - usb_z;
            clamp_depth = 4.0; // How far into the case the clamp reaches

            // Top Row Clamps
            for(x = usb_top_x) {
                translate([x - u_slot_w/2, case_max_y - clamp_depth, -tab_drop])
                cube([u_slot_w, clamp_depth, tab_drop]);
            }
            // Bottom Row Clamps
            for(x = usb_bot_x) {
                translate([x - u_slot_w/2, case_min_y, -tab_drop])
                cube([u_slot_w, clamp_depth, tab_drop]);
            }
            // Left Tab Clamp
            translate([case_min_x, usb_in_y - u_slot_w/2, -tab_drop])
            cube([clamp_depth, u_slot_w, tab_drop]);
        }

        // --- Subtract USB Outlines from the internal pillars to form the perfect arch contour ---
        tab_z_local = -(total_internal_height + base_thickness - usb_z);

        // We use the basic pill shape here so it tightly cradles the rectangular metal connector body
        for(x = usb_top_x) translate([x, case_max_y, tab_z_local]) rotate([-90, 0, 0]) pill(9.5, 3.5, 20);
        for(x = usb_bot_x) translate([x, case_min_y, tab_z_local]) rotate([90, 0, 0]) pill(9.5, 3.5, 20);

        translate([case_min_x, usb_in_y, tab_z_local]) rotate([90, 0, -90]) pill(9.5, 3.5, 20);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=6, h=standoff_h);
        translate([0,0,1]) cylinder(d=2.2, h=standoff_h);
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_tray();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_lid();
}
