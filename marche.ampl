/*choix du résolveur */

/*option solver gurobi;*/


/*ENSEMBLES */

set DIVISIONS;
set DETAILLANTS;
set REGIONS;
set CATEGORIES;


/*PARAMETRES */

/*paramètres concernant les données de DETAILLANTS*/

param region {DETAILLANTS} symbolic in REGIONS;
param huile {DETAILLANTS} >= 0;
param nb_pts_vente {DETAILLANTS} >=0; 
param spiritueux {DETAILLANTS} >=0;
param categorie {DETAILLANTS} symbolic in CATEGORIES;

/*paramètres concernant les données de DIVISIONS */

param repartition_part_min {DIVISIONS} >=0;
param repartition_part_max {DIVISIONS} >=0;
param repartition_opt_part {DIVISIONS} >=0;

/*VARIABLES*/

var repartition_detaillant{DETAILLANTS} binary;

/*variables qui représentent une proportion*/

var proportion_points_de_vente >=0;
var proportion_spiritueux >= 0;
var proportion_huile >=0;
var proportion_categories >=0; 

/*variables utiles à la minimisation des valeurs absolues*/

var z_points_vente >=0;
var z_spiritueux >=0;
var z_huile {REGIONS} >=0;
var z_categories {CATEGORIES} >=0;

/*CONTRAINTES */ 

/*definition des variables de proportion*/

subject to calcul_part_points_de_vente : 
	
	proportion_points_de_vente = 
	(sum {det in DETAILLANTS} nb_pts_vente[det]*repartition_detaillant[det])/ sum {det in DETAILLANTS} nb_pts_vente[det] * 100;

subject to calcul_part_spiritueux : 
	proportion_spiritueux = 
	(sum {det in DETAILLANTS} spiritueux[det]*repartition_detaillant[det])/ sum {det in DETAILLANTS} spiritueux[det] * 100;

subject to calcul_part_huile{r in REGIONS}: 
	proportion_huile = 
	(sum {det in DETAILLANTS : region[det] = r} huile[det] * repartition_detaillant[det])/sum {det in DETAILLANTS : region[det] = r} huile[det] * 100;

subject to calcul_part_categories {c in CATEGORIES}: 
	proportion_categories = 
	(sum{det in DETAILLANTS : categorie[det] = c} 1 * repartition_detaillant[det])/sum{det in DETAILLANTS : categorie[det] = c} 1 * 100;

/* contraintes sur le nombre total de points de vente */

subject to nb_total_points_vente_min {d in DIVISIONS} : 
	 proportion_points_de_vente >= repartition_part_min[d];

subject to nb_total_points_vente_max {d in DIVISIONS} : 
	proportion_points_de_vente  <= repartition_part_max[d];

/* contraintes sur le marche total des spiritueux */

subject to marche_spiritueux_min {d in DIVISIONS}  :
 	proportion_spiritueux >= repartition_part_min[d];

subject to marche_spiritueux_max {d in DIVISIONS}  :
	proportion_spiritueux <= repartition_part_max[d];

/*contraintes sur le marche de l'huile par région */

subject to marche_huile_min {r in REGIONS , d in DIVISIONS}: 
	proportion_huile >= repartition_part_min[d];

subject to marche_huile_max {r in REGIONS , d in DIVISIONS}: 
	proportion_huile <= repartition_part_max[d];

/*contraintes sur la repartition des points de vente par catégories */

subject to nb_detaillants_categories_min {c in CATEGORIES, d in DIVISIONS}: 
	proportion_categories >= repartition_part_min[d];

subject to nb_detaillants_categories_max {c in CATEGORIES, d in DIVISIONS}: 
	proportion_categories <= repartition_part_max[d];

/*contraintes pour la minimisation*/

subject to idealisation_proportion_points_de_vente {d in DIVISIONS}: 
	proportion_points_de_vente = z_points_vente - repartition_opt_part[d];

subject to idealisation_proportion_spiritueux {d in DIVISIONS} : 
	proportion_spiritueux = z_spiritueux - repartition_opt_part[d];

subject to idealisation_proportion_huile{ r in REGIONS, d in DIVISIONS } : 
	proportion_huile = z_huile [r] - repartition_opt_part[d];

subject to idealisation_proportion_categories { c in CATEGORIES, d in DIVISIONS } :
	proportion_categories = z_categories [c] - repartition_opt_part[d];


/*OBJECTIFS*/

minimize somme_vabs_points_de_vente {d in DIVISIONS} : 
	z_points_vente + repartition_opt_part[d];

minimize somme_vabs_spiritueux {d in DIVISIONS} : 
	z_spiritueux + repartition_opt_part[d]; 

minimize somme_vabs_huile {r in REGIONS, d in DIVISIONS} : 
	z_huile[r] + repartition_opt_part[d]; 

minimize somme_vabs_categories{ c in CATEGORIES, d in DIVISIONS } : 
	z_categories[c] + repartition_opt_part[d];


/*DONNEES*/

data;

set DIVISIONS := D1 D2;
set DETAILLANTS := M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 M20 M21 M22 M23;
set REGIONS := R1 R2 R3;
set CATEGORIES := A B;

param : repartition_part_min repartition_part_max repartition_opt_part:=
D1		35 45 40
D2		55 65 60;


param : region huile nb_pts_vente spiritueux categorie :=
 M1       R1        9        11          34         A
 M2       R1       13        47         411         A
 M3       R1       14        44          82         A
 M4       R1       17        25         157         B
 M5       R1       18        10           5         A
 M6       R1       19        26         183         A
 M7       R1       23        26          14         B
 M8       R1       21        54         215         B
 M9       R2        9        18         102         B
 M10      R2       11        51          21         A
 M11      R2       17        20          54         B
 M12      R2       18       105           0         B
 M13      R2       18         7           6         B
 M14      R2       17        16          96         B
 M15      R2       22        34         118         A
 M16      R2       24       100         112         B
 M17      R2       36        50         535         B
 M18      R2       43        21           8         B
 M19      R3        6        11          53         B
 M20      R3       15        19          28         A
 M21      R3       15        14          69         B
 M22      R3       25        10          65         B
 M23      R3       39        11          27         B;
