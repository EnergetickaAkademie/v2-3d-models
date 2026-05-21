$fn = 60;

render_mode = 2; // [0:Bottom Tray, 1:Top Lid, 2:Both (Exploded)]

// --- Board Dimensions ---
board_w = 43.0;
board_h = 38.0;
board_clearance = 1.0; 

// --- Extracted Board Coordinates ---
usb_top_x = [];
usb_bot_x = [];
usb_in_y = 125.73;

h1 = [13.46, 140.34]; // Top Left
h2 = [50.55, 140.46]; // Top Right
h3 = [50.42, 108.59]; // Bot Right
h4 = [13.46, 108.59]; // Bot Left

// --- Parametric Case Boundaries ---
board_center_x = (h1[0] + h2[0] + h3[0] + h4[0]) / 4;
board_center_y = (h1[1] + h2[1] + h3[1] + h4[1]) / 4;

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

case_min_x = board_center_x - (case_width / 2); 
case_max_x = board_center_x + (case_width / 2); 
case_min_y = board_center_y - (case_length / 2);
case_max_y = board_center_y + (case_length / 2);

wall_thickness = 1.5; 

// --- Z-Axis Hardware Stack (Bottom Up) ---
base_thickness = 2.0;
standoff_h = 4.0; 
pcb_thickness = 1.6;

usb_center_above_pcb = 1.6; 
usb_z = base_thickness + standoff_h + pcb_thickness + usb_center_above_pcb; 

clearance_above_pcb = 10.0; 
total_internal_height = standoff_h + pcb_thickness + clearance_above_pcb; 

// --- Fit Tolerances & Shapes ---
fit_tolerance = 0.00; 
friction_lip_depth = 6.0; 

u_slot_w = 11.5; 

explode_dist = (render_mode == 2) ? 25 : 0; 

module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module bottom_tray() {
    difference() {
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, total_internal_height + base_thickness]);
        
        translate([case_min_x, case_min_y, base_thickness])
            cube([case_width, case_length, total_internal_height + 1]);

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
            translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
                cube([case_width + 2*wall_thickness, case_length + 2*wall_thickness, wall_thickness]);

            translate([case_min_x + fit_tolerance, case_min_y + fit_tolerance, -friction_lip_depth])
                difference() {
                    cube([case_width - 2*fit_tolerance, case_length - 2*fit_tolerance, friction_lip_depth]);
                    translate([wall_thickness, wall_thickness, -1])
                        cube([case_width - 2*fit_tolerance - 2*wall_thickness, case_length - 2*fit_tolerance - 2*wall_thickness, friction_lip_depth + 2]);
                }

            tab_drop = total_internal_height + base_thickness - usb_z; 
            clamp_depth = 4.0;

            translate([case_min_x, usb_in_y - u_slot_w/2, -tab_drop])
                cube([clamp_depth, u_slot_w, tab_drop]);
        }

        tab_z_local = -(total_internal_height + base_thickness - usb_z);
        translate([case_min_x, usb_in_y, tab_z_local]) rotate([90, 0, -90]) pill(9.5, 3.5, 20);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=5.5, h=standoff_h); 
        translate([0,0,1]) cylinder(d=2.0, h=standoff_h); 
    }
}

if (render_mode == 0 || render_mode == 2) {
    color("DarkSlateGray") bottom_tray();
}

if (render_mode == 1 || render_mode == 2) {
    color("LightGray") top_lid();
}