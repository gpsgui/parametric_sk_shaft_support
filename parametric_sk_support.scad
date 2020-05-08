/*
Author :    Guilherme Pontes (gpsgui)
github :    www.github.com/gpsgui

Release Notes

08/05/2020 -> Version 1.0.0
        Features:
            - 10 possibles presets(sk8 to sk40) of SAMICK-like SK shaft supports
            - Custom mode, generate a suport with arbitrary dimensions 
            - All holes with countersink or counterbore
            - Clamping with bolt and nut (with nut housing)
*/


/* [Hidden] */
$fn = 64;
// presets based on the manufacturer datasheet http://www.mysamick.com/English/product/goods_list.asp?lcode=E1&mcode=03
// presets with parameters [ d, h, A, W, H, T, E, D, C, B, S, J ]
sk8  = [8, 20, 21, 42, 32.8, 6, 18, 5, 32, 14, 5.5, 4] ;
sk10 = [10, 20, 21, 42, 32.8, 6, 18, 5, 32, 14, 5.5, 4]; 
sk12 = [12, 23, 21, 42, 38, 6, 20, 5, 32, 14, 5.5, 4];
sk13 = [13, 23, 21, 42, 38, 6, 20, 5, 32, 14, 5.5, 4]; 
sk16 = [16, 27, 24, 48, 44, 8, 25, 5, 38, 16, 5.5, 4];
sk20 = [20, 31, 30, 60, 51, 10, 30, 7.5, 45, 20, 6.6, 5];
sk25 = [25, 35, 35, 70, 60, 12, 38, 7, 56, 24, 6.6, 6]; 
sk30 = [30, 42, 42, 84, 70, 12, 44, 10, 64, 28, 9, 6]; 
sk35 = [35, 50, 49, 98, 85, 15, 50, 12, 74, 32, 11, 8];
sk40 = [40, 60, 57, 114, 96, 15, 60, 12, 90, 36, 11, 8];
presets = [[], sk8, sk10, sk12, sk13, sk16, sk20, sk25, sk30, sk35, sk40];
/* [Select SK support preset] */
// If don't want to use a preset, choose "custom"
preset = 0; // [0:custom, 1:sk08, 2:sk10, 3:sk12, 4:sk13, 5:sk16, 6:sk20, 7:sk25, 8:sk30, 9:sk35, 10:sk40]
echo(preset);
/* [Custom dimensions] */
// shaft diameter
d = 8;    
// heigth of the shaft
h = 20;
// horizontal distance between the shaft and the end of the support
A = 21;
// total weigh
W = 2*A;
// total height
H = 32.8;
// base tickness
T = 6;
// length of the part around the shaft
E = 18;
// distance between the center of locking bolt and the edge of the support
D = 5;
// distance between bolts
C = 32;
// thickness of support
B = W/3;
// locking bolts hole diameter
S = 5.5;
// clamping bolts metric size
J = 2;
// bolean for threaded clamp 
is_threaded_clamp = false;


/* [Finishing] */
// clearance
clearance = 0.1;
//bolt counterbore shape
bolt_counterbore_shape = "conical"; // [conical, hex, cylindrical]
// distance between parallel faces of the nut
F_nut = 4; 

// -------------------------------------------------------------------

// shaft diameter
this_d = preset != 0 ? presets[preset][0] : d;    
// heigth of the shaft
this_h = preset != 0 ? presets[preset][1] : h;

// horizontal distance between the shaft and the end of the support
this_A = preset != 0 ? presets[preset][2] : A;

// total weigh
this_W = preset != 0 ? presets[preset][3] : 2*A;

// total height
this_H = preset != 0 ? presets[preset][4] : H;

// base tickness
this_T = preset != 0 ? presets[preset][5] : T;

// length of the part around the shaft
this_E = preset != 0 ? presets[preset][6] : E;

// distance between the center of locking bolt and the edge of the support
this_D = preset != 0 ? presets[preset][7] :D;

// distance between bolts
this_C = preset != 0 ? presets[preset][8] : C;

// thickness of support
this_B = preset != 0 ? presets[preset][9] : W/3;

// locking bolts hole diameter
this_S = preset != 0 ? presets[preset][10] : S;

// clamping bolts metric size
this_J = preset != 0 ? presets[preset][11] : J;

// gap for clamping the shaft
gap = this_B/9;
  
module hexagon(r,h){
    x = 0;
    y = 0;
    linear_extrude(height = h, center = true, twist = 0)
    polygon(points=[[(r+x),(r*(tan(30)))+y],
                [x,(r*(2/sqrt(3)))+y],
                [-r+x,(r*(tan(30)))+y],
                [-r+x,-(r*(tan(30)))+y],
                [x,-(r*(2/sqrt(3)))+y], 
                [r+x,-(r*(tan(30)))+y]]);
     
 }

difference(){
    // creating the flat T block
    union(){
        translate([0,0,this_T/2]) cube([this_W,this_B,this_T], center = true);
        translate([0,0,this_H/2 + this_T/2]) cube([this_E,this_B,this_H-this_T], center = true);
    }
    
    // shaft hole
    translate([0, 0, this_h]) rotate([90,0,0]) cylinder(r = this_d/2 + clearance, h = this_B, center = true);
    
    // bolts 
    translate([this_C/2,0,this_T/2]) cylinder(r = this_S/2 + clearance, h = this_T, center = true);
    translate([-this_C/2,0,this_T/2]) cylinder(r = this_S/2 + clearance, h = this_T, center = true);
    
    // gap for clamping
    translate([0,0,this_H-(this_H-this_h-this_d/2)/2]) cube([gap,this_B,this_H-this_h-this_d/2], center = true);
    
    // clamping bolt holes
    translate([0, 0, this_H-(this_H-this_h-this_d/2)/2]) rotate([0, 90, 0]) cylinder(r = this_J/2 + clearance, h = this_E, center = true);
    
    // locking and clamping bolt counterbore
    if(bolt_counterbore_shape == "conical"){
        translate([this_C/2,0,this_T]) cylinder(r1= 0.4*this_S,r2 = 0.8*this_S, h = 0.4*this_S, center = true);
        translate([-this_C/2,0,this_T]) cylinder(r1= 0.4*this_S,r2 = 0.8*this_S, h = 0.4*this_S, center = true);
        translate([-this_E/2 + 0.2*this_J, 0, this_H-(this_H-this_h-this_d/2)/2]) rotate([0,-90,0]) cylinder(r1= 0.4*this_J,r2 = 0.8*this_J, h = 0.4*this_J, center = true);
    } else if( bolt_counterbore_shape == "cylindrical"){
        translate([this_C/2,0,this_T - 0.75*this_J/2]) cylinder(r = this_J, h = 0.75*this_J, center = true);
        translate([-this_C/2,0,this_T - 0.75*this_J/2]) cylinder(r = this_J, h = 0.75*this_J, center = true);
        translate([-this_E/2 + 0.75*this_J/2, 0, this_H-(this_H-this_h-this_d/2)/2]) rotate([0,-90,0]) cylinder(r = this_J, h = 0.75*this_J, center = true);
    } else {
        
    }
    
    // shaft countersink
    translate([0,-this_B/2,this_h]) rotate([90,0,0]) cylinder(r1= 0.4*this_d,r2 = 0.8*this_d, h = 0.4*this_d, center = true);
    translate([0,this_B/2,this_h]) rotate([270,0,0]) cylinder(r1= 0.4*this_d,r2 = 0.8*this_d, h = 0.4*this_d, center = true);
      
    // Nut housing
    translate([this_E/2 - 0.75*this_J/2, 0, this_H-(this_H-this_h-this_d/2)/2]) rotate([0,-90,0]) hexagon(0.75*this_J,0.75*this_J);
}
