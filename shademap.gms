$ontext
This is a GAMS to SHADEMAP interface developed by Uwe Schneider
$offtext

$onlisting
$hidden                Libinclude routine for driving SHADEMAP
$hidden
$hidden                Usage:  $libinclude shademap mapid data [mapping]
$hidden
$hidden                where   mapid.mid/mapid.mif     describe the region ids and boundaries
$hidden                        data                    is a one-dimensional numeric item to be portrayed
$hidden                        mapping(r,s)            associates each map region id (r) with a data element (s)
$hidden

* Assign compile-time variables:
* %mapid%   = %1
* %data%    = %2
* %mapping% = %3
$setargs mapid data mapping
$log     Running SHADEMAP with mapid = %mapid%, data = %data% and mapping = %mapping%

* Check for the .mid file
$if exist %mapid%.mid                             $goto gotmid
$if exist "%gams.sysdir%gislib\%mapid%.mid"       $log Copying MID file to working directory
$if exist "%gams.sysdir%gislib\%mapid%.mid"       $call 'copy "%gams.sysdir%gislib\%mapid%.mid" %mapid%.mid'
$if exist "%gams.sysdir%gislib\%mapid%.mid"       $goto gotmid
$abort Cannot find %mapid%.mid in working directory or gislib gams system sub-directory.
$label gotmid

* Check for the .mif file
$if exist %mapid%.mif $goto gotmif
$if exist "%gams.sysdir%gislib\%mapid%.mif"       $log Copying MIF file to working directory
$if exist "%gams.sysdir%gislib\%mapid%.mif"       $call 'copy "%gams.sysdir%gislib\%mapid%.mif" %mapid%.mif'
$if exist "%gams.sysdir%gislib\%mapid%.mif"       $goto gotmif
$abort Cannot find %mapid%.mid in working directory or gislib gams system sub-directory.
$label gotmif

* Generate sequence sets for writing data to this map:
* Generate set definitions
$if exist "%gams.scrdir%shademap.scr"             $call del "%gams.scrdir%shademap.scr"


* If not existing, create directory for powerpoint stuff
$if not exist %gams.sysdir%pptlib                 $call mkdir %gams.sysdir%pptlib

* Declare powerpoint counter and text file for image list (Huck utility)
$if not declared gpxyzsm_plot_count               scalar gpxyzsm_plot_count /0/;
$if not declared gams_ppt_list                    file gams_ppt_list /'%gams.sysdir%pptlib\gams_ppt_list.txt'/;

* Reset powerpoint if needed
$if '%1' == 'reset'                               execute 'if exist "%gams.sysdir%pptlib\gams_ppt_list.txt" del "%gams.sysdir%pptlib\gams_ppt_list.txt" >nul';
$if '%1' == 'reset'                               gpxyzsm_plot_count = 0;
$if '%1' == 'reset'                               $goto end_of_shademap

* Determine restart file
$if setglobal gpxyzsm_restartfile                 $setglobal gpxyzsm_orgrestartfile "%gpxyzsm_restartfile%"
$setglobal gpxyzsm_restartfile %system.rfile%
$if not setglobal gpxyzsm_restartfile             $goto smlabel_no_new_restart_file
$if "%gpxyzsm_restartfile%" ==""                  $goto smlabel_no_new_restart_file
$if "%gpxyzsm_restartfile%" =="%gpxyzsm_orgrestartfile%"    $goto smlabel_no_new_restart_file

* delete powerpoint file if this is the first execution of gnuplot or shademap after a gams restart
* note some variables are jointly used in the gnuplot and shademap interface
execute 'if exist "%gams.sysdir%pptlib\gams_ppt_list.txt" del "%gams.sysdir%pptlib\gams_ppt_list.txt" >nul';
gpxyzsm_plot_count = 0;
$label smlabel_no_new_restart_file

$if not declared  %mapid%_map  $include  %gams.sysdir%gislib\%mapid%_sm.gms

$if declared shademap_d                           $goto gotdeclarations
$if setglobal dont_delete_list                    $goto  list_file_ready
execute 'if exist "%gams.sysdir%pptlib\gams_ppt_list.txt" del "%gams.sysdir%pptlib\gams_ppt_list.txt" >nul';
$setglobal dont_delete_list  yes
$label  list_file_ready



alias (shademap_u,shademap_uu,*);
files
 shademap_d   /%gams.scrdir%shademap.scr/
 shademap_run /run_shademap.bat/
;
  shademap_d.lw =  0;
  shademap_d.nr =  2;
  shademap_d.nw = 22;
  shademap_d.nd = 13;

  shademap_run.lw = 0;
  shademap_run.nw = 0;
  shademap_run.tw = 0;

SETS
 sm_ppt_repeat_loop_all
  /1*9/
 sm_ppt_repeat_loop(sm_ppt_repeat_loop_all)
 sm_color_name
  /aliceblue '240 248 255',antiquewhite '250 235 215',aqua '0 255 255',aquamarine '127 255 212',azure '240 255 255',beige '245 245 220',
   bisque '255 228 196',black '0 0 0',blanchedalmond '255 235 205',blue '0  0 255',blueviolet '138  43 226',brown '165  42  42',
   BrightCyan '0 255 255',BrightGreen '0 255 0',BrightMagneta '255 0 255',burlywood '222 184 135',cadetblue '95 158 160',chartreuse '127 255  0',
   chocolate '210 105  30',coral '255 127  80',cornflowerblue '100 149 237',cornsilk '255 248 220',crimson '220 20 60',cyan '0 255 255',
   darkblue '0 0 139',darkcyan '0 139 139',darkgoldenrod '184 134  11',darkgray '169 169 169',darkgreen '0 100  0',DarkGrey '128 128 128',
   darkkhaki '189 183 107',darkmagenta '139  0 139',darkolivegreen '85 107  47',darkorange '255 140  0',darkorchid '153  50 204',darkred '139  0  0',
   darksalmon '233 150 122',darkseagreen '143 188 143',darkslateblue '72  61 139',darkslategray '47  79  79',darkturquoise '0 206 209',darkviolet '148  0 211',
   deeppink '255  20 147',deepskyblue '0 191 255',dimgray '105 105 105',dodgerblue '30 144 255',firebrick '178  34  34',floralwhite '255 250 240',
   forestgreen '34 139  34',fuchsia '255 0 255',gainsboro '220 220 220',ghostwhite '248 248 255',gold '255 215  0',goldenrod '218 165  32',
   gray '127 127 127',green '0 128 0',greenyellow '173 255  47',honeydew '240 255 240',hotpink '255 105 180',indianred '205  92  92',
   indigo '75 0 130',ivory '255 255 240',khaki '240 230 140',lavender '230 230 250',lavenderblush '255 240 245',lawngreen '124 252  0',
   lemonchiffon '255 250 205',lightblue '173 216 230',lightcoral '240 128 128',lightcyan '224 255 255',lightgoldenrodyellow '250 250 210',lightgreen '144 238 144',
   lightgrey '211 211 211',lightpink '255 182 193',lightsalmon '255 160 122',lightseagreen '32 178 170',lightskyblue '135 206 250',lightslategray '119 136 153',
   lightsteelblue '176 196 222',lightyellow '255 255 224',lime '0 255 0',limegreen '50 205  50',linen '250 240 230',magenta '255  0 255',
   Magneta '128 0 128',maroon '128 0 0',mediumaquamarine '102 205 170',mediumblue '0 0 205',mediumorchid '186  85 211',mediumpurple '147 112 219',
   mediumseagreen '60 179 113',mediumslateblue '123 104 238',mediumspringgreen '0 250 154',mediumturquoise '72 209 204',mediumvioletred '199  21 133',midnightblue '25  25 112',
   mintcream '245 255 250',mistyrose '255 228 225',moccasin '255 228 181',navajowhite '255 222 173',navy '0  0 128',navyblue '159 175 223',
   oldlace '253 245 230',olive '128 128 0',olivedrab '107 142  35',orange '255 165  0',orangered '255  69  0',orchid '218 112 214',
   palegoldenrod '238 232 170',palegreen '152 251 152',paleturquoise '175 238 238',palevioletred '219 112 147',papayawhip '255 239 213',peachpuff '255 218 185',
   peru '205 133  63',pink '255 192 203',plum '221 160 221',powderblue '176 224 230',purple '128 0 128',red '255  0  0',
   rosybrown '188 143 143',royalblue '65 105 225',saddlebrown '139 69 19',salmon '250 128 114',sandybrown '244 164  96',seagreen '46 139  87',
   seashell '255 245 238',sienna '160  82  45',silver '192 192 192',skyblue '135 206 235',slateblue '106  90 205',slategray '112 128 144',
   snow '255 250 250',springgreen '0 255 127',steelblue '70 130 180',tan '210 180 140',teal '0 128 128',thistle '216 191 216',
   tomato '255  99  71',turquoise '64 224 208',violet '238 130 238',wheat '245 222 179',white '255 255 255',whitesmoke '245 245 245',
   yellow '255 255  0',yellowgreen '139 205 50'/;
 SET sm_ind_col(*)
;

$label gotdeclarations

$if "%2" == "loop"                             $goto end_of_shademap



$hidden        Define a temporary file in which to pass data:

$if defined shademap_u $goto gotfiles
alias (shademap_u,shademap_uu,*);
file shademap_d /%gams.scrdir%shademap.scr/;
shademap_d.lw =  0;
shademap_d.nr =  2;
shademap_d.nw = 22;
shademap_d.nd = 13;

*       Write the data file:

$label gotfiles
$onuni
put shademap_d;

loop(%mapid%_map(%mapid%_r,shademap_u),
$if not "%mapping%"=="" loop(%mapping%(shademap_u,shademap_uu),put %data%(shademap_uu)/;);
$if     "%mapping%"=="" put %data%(shademap_u)/;
);
$offuni
putclose;
execute 'sleep 1';
execute 'copy "%gams.scrdir%shademap.scr" "%mapid%_%data%.txt"';


* Options

shademap_d.lw=0;
put shademap_d;


* LowColor 180 255 255  ! Color for smallest score [3 integers RGB value]
$if not setglobal sm_LowColor   $goto gotlowcolor
$if "%sm_LowColor%" == "0"      put "LowColor 128 255 255" /;
$if "%sm_LowColor%" == "no"     put "LowColor 128 255 255" /;
$if "%sm_LowColor%" == "0"      $goto gotlowcolor
$if "%sm_LowColor%" == "no"     $goto gotlowcolor
$if setglobal sm_LowColor       sm_ind_col("%sm_LowColor%") = yes;
LOOP(sm_color_name $sm_ind_col(sm_color_name),
 put "LowColor ",sm_color_name.te(sm_color_name) /;
    );
$if setglobal sm_LowColor       sm_ind_col("%sm_LowColor%") = no;
$label gotlowcolor


* MidColor 225 225 90  ! Color for median score [3 integers RGB value]
$if not setglobal sm_MidColor   $goto gotmidcolor
$if "%sm_MidColor%" == "0"      put "MidColor 128 255 128" /;
$if "%sm_MidColor%" == "no"     put "MidColor 128 255 128" /;
$if "%sm_MidColor%" == "0"      $goto gotmidcolor
$if "%sm_MidColor%" == "no"     $goto gotmidcolor
$if setglobal sm_MidColor       sm_ind_col("%sm_MidColor%") = yes;
LOOP(sm_color_name $sm_ind_col(sm_color_name),
 put "MidColor ",sm_color_name.te(sm_color_name) /;
    );
$if setglobal sm_MidColor       sm_ind_col("%sm_MidColor%") = no;
$label gotmidcolor

* HighColor 255 100 100  ! Color for highest score [3 integers RGB value]
$if not setglobal sm_HighColor   $goto gothighcolor
$if "%sm_HighColor%" == "0"      put "HighColor 255 128 128" /;
$if "%sm_HighColor%" == "no"     put "HighColor 255 128 128" /;
$if "%sm_HighColor%" == "0"      $goto gothighcolor
$if "%sm_HighColor%" == "no"     $goto gothighcolor
$if setglobal sm_HighColor       sm_ind_col("%sm_HighColor%") = yes;
LOOP(sm_color_name $sm_ind_col(sm_color_name),
 put "HighColor ",sm_color_name.te(sm_color_name) /;
    );
$if setglobal sm_HighColor       sm_ind_col("%sm_HighColor%") = no;
$label gothighcolor

* RegLineColor 255 255 255  ! Color for region boundaries [3 integers RGB value]
$if not setglobal sm_RegLineColor   put "RegLineColor 0 0 0" /;
$if "%sm_RegLineColor%" == "0"      put "RegLineColor 0 0 0" /;
$if "%sm_RegLineColor%" == "no"     put "RegLineColor 0 0 0" /;
$if not setglobal sm_RegLineColor   $goto gotRegLineColor
$if "%sm_RegLineColor%" == "0"      $goto gotRegLineColor
$if "%sm_RegLineColor%" == "no"     $goto gotRegLineColor
$if setglobal sm_RegLineColor       sm_ind_col("%sm_RegLineColor%") = yes;
LOOP(sm_color_name $sm_ind_col(sm_color_name),
 put "RegLineColor ",sm_color_name.te(sm_color_name) /;
    );
$if setglobal sm_RegLineColor       sm_ind_col("%sm_RegLineColor%") = no;
$label gotRegLineColor


* BackgroundColor 200 255 255  ! Color for background or sea [3 integers RGB value]
$if not setglobal sm_BackgroundColor   put "BackgroundColor 0 128 192" /;
$if "%sm_BackgroundColor%" == "0"      put "BackgroundColor 0 128 192" /;
$if "%sm_BackgroundColor%" == "no"     put "BackgroundColor 0 128 192" /;
$if not setglobal sm_BackgroundColor   $goto gotBackgroundColor
$if "%sm_BackgroundColor%" == "0"      $goto gotBackgroundColor
$if "%sm_BackgroundColor%" == "no"     $goto gotBackgroundColor
$if setglobal sm_BackgroundColor       sm_ind_col("%sm_BackgroundColor%") = yes;
LOOP(sm_color_name $sm_ind_col(sm_color_name),
 put "BackgroundColor ",sm_color_name.te(sm_color_name) /;
    );
$if setglobal sm_BackgroundColor       sm_ind_col("%sm_BackgroundColor%") = no;
$label gotBackgroundColor



* RegLineWidth 0  ! Line width for region boundaries (0..3) [Integer]
$if not setglobal sm_RegLineWidth             PUT "RegLineWidth 0" /;
$if "%sm_RegLineWidth%" == "0"                PUT "RegLineWidth 0" /;
$if "%sm_RegLineWidth%" == "no"               PUT "RegLineWidth 0" /;
$if "%sm_RegLineWidth%" == "0"                $goto after_RegLineWidth
$if "%sm_RegLineWidth%" == "no"               $goto after_RegLineWidth
$if setglobal sm_RegLineWidth                 PUT "RegLineWidth %sm_RegLineWidth%" /;
$label after_RegLineWidth


* LineWidth 0                   ! Line width (0..3) [Integer]
$if not setglobal sm_LineWidth             PUT "LineWidth 0" /;
$if "%sm_LineWidth%" == "0"                PUT "LineWidth 0" /;
$if "%sm_LineWidth%" == "no"               PUT "LineWidth 0" /;
$if "%sm_LineWidth%" == "0"                $goto after_LineWidth
$if "%sm_LineWidth%" == "no"               $goto after_LineWidth
$if setglobal sm_LineWidth                 PUT "LineWidth %sm_LineWidth%" /;
$label after_LineWidth

* FontSize 6                    ! Font Size (4..10) [Integer]
$if not setglobal sm_FontSize              PUT "FontSize 6" /;
$if setglobal sm_FontSize                  PUT "FontSize %sm_FontSize%" /;

* SpaceAround 10                ! Border width (5..20) [Integer]
$if not setglobal sm_SpaceAround           PUT "SpaceAround 0" /;
$if "%sm_SpaceAround%" == "no"             PUT "SpaceAround 0" /;
$if "%sm_SpaceAround%" == "false"          PUT "SpaceAround 0" /;
$if "%sm_SpaceAround%" == "no"             $goto after_SpaceAround
$if "%sm_SpaceAround%" == "false"          $goto after_SpaceAround
$if setglobal sm_SpaceAround               PUT "SpaceAround %sm_SpaceAround%" /;
$label after_SpaceAround

* DesiredWidth 700              ! Width of map (500..1500) [Integer]
$if not setglobal sm_DesiredWidth          PUT "DesiredWidth 700" /;
$if setglobal sm_DesiredWidth              PUT "DesiredWidth %sm_DesiredWidth%" /;

* ScoreNDec 2                   ! No. of decimal places for scores in color key (0..4) [Integer]
$if not setglobal sm_ScoreNDec             PUT "ScoreNDec 2" /;
$if setglobal sm_ScoreNDec                 PUT "ScoreNDec %sm_ScoreNDec%" /;

* LegendPos 10 10               ! Color key position: Left Top as % of Map size (10..90) [2 integers]
$if not setglobal sm_LegendPos             PUT "LegendPos 10 10" /;
$if setglobal sm_LegendPos                 PUT "LegendPos %sm_LegendPos%" /;

* TitlePos 50 95  ! Position of centre of Title: Left, Top as % of Map size (10..90) [2 integers]
$if not setglobal sm_TitlePos              PUT "TitlePos 50 95" /;
$if setglobal sm_TitlePos                  PUT "TitlePos %sm_TitlePos%" /;

* Title   ! Map title: blank for no title [String]
$if setglobal sm_ppt                       PUT "Title" /;
$if setglobal sm_ppt                       $goto after_sm_title
$if not setglobal sm_Title                 PUT "Title";
$if setglobal sm_Title                     PUT "Title %sm_Title%";
$if "%sm_loop1%" == "no"                   PUT /;
$if "%sm_loop1%" == "no"                   $goto after_sm_title
$if setglobal sm_loop1                     PUT " ",%sm_loop1%.te(%sm_loop1%);
$if "%sm_loop2%" == "no"                   PUT /;
$if "%sm_loop2%" == "no"                   $goto after_sm_title
$if setglobal sm_loop2                     PUT " ",%sm_loop2%.te(%sm_loop2%);
$if "%sm_loop3%" == "no"                   PUT /;
$if "%sm_loop3%" == "no"                   $goto after_sm_title
$if setglobal sm_loop3                     PUT " ",%sm_loop3%.te(%sm_loop3%);
$if "%sm_loop4%" == "no"                   PUT /;
$if "%sm_loop4%" == "no"                   $goto after_sm_title
$if setglobal sm_loop4                     PUT " ",%sm_loop4%.te(%sm_loop4%);
$if "%sm_loop5%" == "no"                   PUT /;
$if "%sm_loop5%" == "no"                   $goto after_sm_title
$if setglobal sm_loop5                     PUT " ",%sm_loop5%.te(%sm_loop5%);
$if "%sm_loop6%" == "no"                   PUT /;
$if "%sm_loop6%" == "no"                   $goto after_sm_title
$if setglobal sm_loop6                     PUT " ",%sm_loop6%.te(%sm_loop6%);
$if "%sm_loop7%" == "no"                   PUT /;
$if "%sm_loop7%" == "no"                   $goto after_sm_title
$if setglobal sm_loop7                     PUT " ",%sm_loop7%.te(%sm_loop7%);
$if "%sm_loop8%" == "no"                   PUT /;
$if "%sm_loop8%" == "no"                   $goto after_sm_title
$if setglobal sm_loop8                     PUT " ",%sm_loop8%.te(%sm_loop8%);
PUT /;
$goto  after_sm_title
$label after_sm_title





* yytrans 120                   ! Stretch map vertically (80..120 100=no stretch) [Integer]
$if not setglobal sm_yytrans               PUT "yytrans 100" /;
$if "%sm_yytrans%" == "false"              PUT "yytrans 100" /;
$if "%sm_yytrans%" == "no"                 PUT "yytrans 100" /;
$if "%sm_yytrans%" == "false"              $goto after_yytrans
$if "%sm_yytrans%" == "no"                 $goto after_yytrans
$if setglobal sm_yytrans                   PUT "yytrans %sm_yytrans%" /;
$label after_yytrans

* xDistort 0                    ! Positive values stretch right of map more than left (-30..+30 0=no distortion) [Integer]
$if not setglobal sm_xDistort              PUT "xDistort 0" /;
$if "%sm_xDistort%" == "no"                PUT "xDistort 0" /;
$if "%sm_xDistort%" == "false"             PUT "xDistort 0" /;
$if "%sm_xDistort%" == "no"                $goto after_xDistort
$if "%sm_xDistort%" == "false"             $goto after_xDistort
$if setglobal sm_xDistort                  PUT "xDistort %sm_xDistort%" /;
$label after_xDistort

* yDistort 0                    ! Positive values stretch top of map more than bottom (-30..+30 0=no distortion) [Integer]
$if not setglobal sm_yDistort              PUT "yDistort 0" /;
$if "%sm_yDistort%" == "no"                PUT "yDistort 0" /;
$if "%sm_yDistort%" == "false"             PUT "yDistort 0" /;
$if "%sm_yDistort%" == "no"                $goto after_yDistort
$if "%sm_yDistort%" == "false"             $goto after_yDistort
$if setglobal sm_yDistort                  PUT "yDistort %sm_yDistort%" /;
$label after_yDistort

* AutoScale True  ! Use automatic color scale [Boolean]
$if not setglobal sm_AutoScale             PUT "AutoScale True" /;
$if "%sm_AutoScale%" == "0"                PUT "AutoScale False" /;
$if "%sm_AutoScale%" == "no"               PUT "AutoScale False" /;
$if "%sm_AutoScale%" == "false"            PUT "AutoScale False" /;
$if "%sm_AutoScale%" == "0"                $goto after_AutoScale
$if "%sm_AutoScale%" == "no"               $goto after_AutoScale
$if "%sm_AutoScale%" == "false"            $goto after_AutoScale
$if setglobal sm_AutoScale                 PUT "AutoScale True" /;
$label after_AutoScale

* ScaleBounds 1.0 10.0  ! Min and max for color scale (if not automatic) [2 real numbers]
$if not setglobal sm_ScaleBounds           PUT "ScaleBounds 1.0 10.0" /;
$if setglobal sm_ScaleBounds               PUT "ScaleBounds %sm_ScaleBounds%" /;

* OrdinalShades False  ! Shade regions according to rank [Boolean]
$if not setglobal sm_OrdinalShades         PUT "OrdinalShades False" /;
$if "%sm_OrdinalShades%" == "0"            PUT "OrdinalShades False" /;
$if "%sm_OrdinalShades%" == "no"           PUT "OrdinalShades False" /;
$if "%sm_OrdinalShades%" == "false"        PUT "OrdinalShades False" /;
$if "%sm_OrdinalShades%" == "0"            $goto after_ordinalshades
$if "%sm_OrdinalShades%" == "no"           $goto after_ordinalshades
$if "%sm_OrdinalShades%" == "false"        $goto after_ordinalshades
$if setglobal sm_OrdinalShades             PUT "OrdinalShades True" /;
$label after_ordinalshades

* RGBScores False  ! Treat scores as RGB integers [Boolean]
$if not setglobal sm_RGBScores             PUT "UseGreys False" /;
$if "%sm_UseGreys%" == "0"                 PUT "UseGreys False" /;
$if "%sm_UseGreys%" == "no"                PUT "UseGreys False" /;
$if "%sm_UseGreys%" == "false"             PUT "UseGreys False" /;
$if "%sm_UseGreys%" == "0"                 $goto after_UseGreys
$if "%sm_UseGreys%" == "no"                $goto after_UseGreys
$if "%sm_UseGreys%" == "false"             $goto after_UseGreys
$if setglobal sm_RGBScores                 PUT "UseGreys True" /;
$label after_UseGreys

$if not setglobal sm_RGBScores             PUT "RGBScores False" /;
$if "%sm_RGBScores%" == "0"                PUT "RGBScores False" /;
$if "%sm_RGBScores%" == "no"               PUT "RGBScores False" /;
$if "%sm_RGBScores%" == "false"            PUT "RGBScores False" /;
$if "%sm_RGBScores%" == "0"                $goto after_RGBScores
$if "%sm_RGBScores%" == "no"               $goto after_RGBScores
$if "%sm_RGBScores%" == "false"            $goto after_RGBScores
$if setglobal sm_RGBScores                 PUT "RGBScores True" /;
$label after_RGBScores

* ShowScores False  ! Show region scores at region centres [Boolean]
$if not setglobal sm_ShowScores            PUT "ShowScores False" /;
$if "%sm_ShowScores%" == "0"               PUT "ShowScores False" /;
$if "%sm_ShowScores%" == "no"              PUT "ShowScores False" /;
$if "%sm_ShowScores%" == "false"           PUT "ShowScores False" /;
$if "%sm_ShowScores%" == "0"               $goto after_ShowScores
$if "%sm_ShowScores%" == "no"              $goto after_ShowScores
$if "%sm_ShowScores%" == "false"           $goto after_ShowScores
$if setglobal sm_ShowScores                PUT "ShowScores True" /;
$label after_ShowScores

* NumberRegions False  ! Show region numbers at region centres [Boolean]
$if not setglobal sm_NumberRegions         PUT "NumberRegions False" /;
$if "%sm_NumberRegions%" == "0"            PUT "NumberRegions False" /;
$if "%sm_NumberRegions%" == "no"           PUT "NumberRegions False" /;
$if "%sm_NumberRegions%" == "false"        PUT "NumberRegions False" /;
$if "%sm_NumberRegions%" == "0"            $goto after_NumberRegions
$if "%sm_NumberRegions%" == "no"           $goto after_NumberRegions
$if "%sm_NumberRegions%" == "false"        $goto after_NumberRegions
$if setglobal sm_NumberRegions             PUT "NumberRegions True" /;
$label after_NumberRegions

* ShowNames False  ! Show region names at region centres [Boolean]
$if not setglobal sm_ShowNames             PUT "ShowNames False" /;
$if "%sm_ShowNames%" == "0"                PUT "ShowNames False" /;
$if "%sm_ShowNames%" == "no"               PUT "ShowNames False" /;
$if "%sm_ShowNames%" == "false"            PUT "ShowNames False" /;
$if "%sm_ShowNames%" == "0"                $goto after_ShowNames
$if "%sm_ShowNames%" == "no"               $goto after_ShowNames
$if "%sm_ShowNames%" == "false"            $goto after_ShowNames
$if setglobal sm_ShowNames                 PUT "ShowNames True" /;
$label after_ShowNames

* NumberRegionPatch False  ! White patch behind region numbers [Boolean]
$if not setglobal sm_NumberRegionPatch     PUT "NumberRegionPatch False" /;
$if "%sm_NumberRegionPatch%" == "0"        PUT "NumberRegionPatch False" /;
$if "%sm_NumberRegionPatch%" == "no"       PUT "NumberRegionPatch False" /;
$if "%sm_NumberRegionPatch%" == "false"    PUT "NumberRegionPatch False" /;
$if "%sm_NumberRegionPatch%" == "0"        $goto after_NumberRegionPatch
$if "%sm_NumberRegionPatch%" == "no"       $goto after_NumberRegionPatch
$if "%sm_NumberRegionPatch%" == "false"    $goto after_NumberRegionPatch
$if setglobal sm_NumberRegionPatch         PUT "NumberRegionPatch True" /;
$label after_NumberRegionPatch

* ShowLegend True  ! Show color key for scores [Boolean]
$if not setglobal sm_ShowLegend            PUT "ShowLegend True" /;
$if "%sm_ShowLegend%" == "0"               PUT "ShowLegend False" /;
$if "%sm_ShowLegend%" == "no"              PUT "ShowLegend False" /;
$if "%sm_ShowLegend%" == "false"           PUT "ShowLegend False" /;
$if "%sm_ShowLegend%" == "0"               $goto after_ShowLegend
$if "%sm_ShowLegend%" == "no"              $goto after_ShowLegend
$if "%sm_ShowLegend%" == "false"           $goto after_ShowLegend
$if setglobal sm_ShowLegend                PUT "ShowLegend True" /;
$label after_ShowLegend

* DotCentroids False  ! Show red dots at region centres [Boolean]
$if not setglobal sm_DotCentroids          PUT "DotCentroids False" /;
$if "%sm_DotCentroids%" == "0"             PUT "DotCentroids False" /;
$if "%sm_DotCentroids%" == "no"            PUT "DotCentroids False" /;
$if "%sm_DotCentroids%" == "false"         PUT "DotCentroids False" /;
$if "%sm_DotCentroids%" == "0"             $goto after_DotCentroids
$if "%sm_DotCentroids%" == "no"            $goto after_DotCentroids
$if "%sm_DotCentroids%" == "false"         $goto after_DotCentroids
$if setglobal sm_DotCentroids              PUT "DotCentroids True" /;
$label after_DotCentroids

* DotPolyStarts False  ! Mark 1st point of each polygon with red dot [Boolean]
$if not setglobal sm_DotPolyStarts         PUT "DotPolyStarts False" /;
$if "%sm_DotPolyStarts%" == "0"            PUT "DotPolyStarts False" /;
$if "%sm_DotPolyStarts%" == "no"           PUT "DotPolyStarts False" /;
$if "%sm_DotPolyStarts%" == "false"        PUT "DotPolyStarts False" /;
$if "%sm_DotPolyStarts%" == "0"            $goto after_DotPolyStarts
$if "%sm_DotPolyStarts%" == "no"           $goto after_DotPolyStarts
$if "%sm_DotPolyStarts%" == "false"        $goto after_DotPolyStarts
$if setglobal sm_DotPolyStarts             PUT "DotPolyStarts True" /;
$label after_DotPolyStarts
putclose;

$ontext
$if not setglobal sm_ppt                   $goto interactive_shademap

sm_plot_count = sm_plot_count + 1;

PUT  gams_ppt_list;
gams_ppt_list.ap = 1;
gams_ppt_list.nw = 0;
gams_ppt_list.lw = 0;
gams_ppt_list.nd = 0;
PUT  "%gams.Workdir%%mapid%_",sm_plot_count,".emf"/;
PUTCLOSE;
$offtext


$if not setglobal sm_ppt      $goto interactive_shademap

gpxyzsm_plot_count = gpxyzsm_plot_count + 1;


sm_ppt_repeat_loop("1") = yes;

$if not setglobal sm_ppt_2    $goto after_checking_ppt2
$if not "%sm_ppt_2%"=="2"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt2

$if not setglobal sm_ppt_3    $goto after_checking_ppt3
$if not "%sm_ppt_3%"=="3"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt3

$if not setglobal sm_ppt_4    $goto after_checking_ppt4
$if not "%sm_ppt_4%"=="4"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt4

$if not setglobal sm_ppt_5    $goto after_checking_ppt5
$if not "%sm_ppt_5%"=="5"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
sm_ppt_repeat_loop("5") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt5

$if not setglobal sm_ppt_6    $goto after_checking_ppt6
$if not "%sm_ppt_6%"=="6"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
sm_ppt_repeat_loop("5") = yes;
sm_ppt_repeat_loop("6") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt6

$if not setglobal sm_ppt_7    $goto after_checking_ppt7
$if not "%sm_ppt_7%"=="7"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
sm_ppt_repeat_loop("5") = yes;
sm_ppt_repeat_loop("6") = yes;
sm_ppt_repeat_loop("7") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt7

$if not setglobal sm_ppt_8    $goto after_checking_ppt8
$if not "%sm_ppt_8%"=="8"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
sm_ppt_repeat_loop("5") = yes;
sm_ppt_repeat_loop("6") = yes;
sm_ppt_repeat_loop("7") = yes;
sm_ppt_repeat_loop("8") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt8

$if not setglobal sm_ppt_9    $goto after_checking_ppt9
$if not "%sm_ppt_9%"=="9"     $goto after_writing_ppt_file
sm_ppt_repeat_loop("2") = yes;
sm_ppt_repeat_loop("3") = yes;
sm_ppt_repeat_loop("4") = yes;
sm_ppt_repeat_loop("5") = yes;
sm_ppt_repeat_loop("6") = yes;
sm_ppt_repeat_loop("7") = yes;
sm_ppt_repeat_loop("8") = yes;
sm_ppt_repeat_loop("9") = yes;
$goto  after_checking_all_ppt
$label after_checking_ppt9

$label after_checking_all_ppt


PUT  gams_ppt_list;
gams_ppt_list.ap = 1;
gams_ppt_list.nw = 0;
gams_ppt_list.lw = 0;
gams_ppt_list.nd = 0;

$if not setglobal sm_ppt_fontname      $setglobal sm_ppt_fontname Arial
$if not setglobal sm_ppt_fontsize      $setglobal sm_ppt_fontsize 40
$if not setglobal sm_ppt_boldfont      $setglobal sm_ppt_boldfont 0
$if   "%sm_ppt_boldfont%"=="yes"       $setglobal sm_ppt_boldfont 1
$if   "%sm_ppt_boldfont%"=="bold"      $setglobal sm_ppt_boldfont 1
$if   "%sm_ppt_boldfont%"=="no"        $setglobal sm_ppt_boldfont 0
$if   "%sm_ppt_boldfont%"=="normal"    $setglobal sm_ppt_boldfont 0

IF(gpxyzsm_plot_count eq 1,
PUT "%sm_ppt_fontname%" /;
PUT "%sm_ppt_boldfont%" /;
PUT "%sm_ppt_fontsize%" /;
  );

LOOP(sm_ppt_repeat_loop,

PUT  "%gams.Workdir%%mapid%_",gpxyzsm_plot_count,"_",sm_ppt_repeat_loop.TL,".emf"/;

* Title
$if "%sm_loop1%"   == "no"                        $goto noloopppttitle
$if "%sm_loop1%"   == "0"                         $goto noloopppttitle
$if     setglobal sm_loop1                        $goto ppttitle_loop1

$label noloopppttitle
$if not setglobal sm_title                        $goto skipppttitle
$if "%sm_title%"   == "no"                        $goto skipppttitle
$if "%sm_title%"   == "0"                         $goto skipppttitle
put '%sm_title%';
$if setglobal sm_ppt_1_name  If(gpxyzsm_plot_count eq 1, put "%sm_ppt_1_name%"; );
$if setglobal sm_ppt_2_name  If(gpxyzsm_plot_count eq 2, put "%sm_ppt_2_name%"; );
$if setglobal sm_ppt_3_name  If(gpxyzsm_plot_count eq 3, put "%sm_ppt_3_name%"; );
$if setglobal sm_ppt_4_name  If(gpxyzsm_plot_count eq 4, put "%sm_ppt_4_name%"; );
$if setglobal sm_ppt_5_name  If(gpxyzsm_plot_count eq 5, put "%sm_ppt_5_name%"; );
$if setglobal sm_ppt_6_name  If(gpxyzsm_plot_count eq 6, put "%sm_ppt_6_name%"; );
$if setglobal sm_ppt_7_name  If(gpxyzsm_plot_count eq 7, put "%sm_ppt_7_name%"; );
$if setglobal sm_ppt_8_name  If(gpxyzsm_plot_count eq 8, put "%sm_ppt_8_name%"; );
$if setglobal sm_ppt_9_name  If(gpxyzsm_plot_count eq 9, put "%sm_ppt_9_name%"; );
put /;
$goto  skipppttitle

$label ppttitle_loop1
$if not setglobal sm_title                        $setglobal sm_title " "
put '%sm_title% ',%sm_loop1%.te(%sm_loop1%);
$if     setglobal sm_loop2                        $goto ppttitle_loop2
$if setglobal sm_ppt_1_name  If(gpxyzsm_plot_count eq 1, put "%sm_ppt_1_name%"; );
$if setglobal sm_ppt_2_name  If(gpxyzsm_plot_count eq 2, put "%sm_ppt_2_name%"; );
$if setglobal sm_ppt_3_name  If(gpxyzsm_plot_count eq 3, put "%sm_ppt_3_name%"; );
$if setglobal sm_ppt_4_name  If(gpxyzsm_plot_count eq 4, put "%sm_ppt_4_name%"; );
$if setglobal sm_ppt_5_name  If(gpxyzsm_plot_count eq 5, put "%sm_ppt_5_name%"; );
$if setglobal sm_ppt_6_name  If(gpxyzsm_plot_count eq 6, put "%sm_ppt_6_name%"; );
$if setglobal sm_ppt_7_name  If(gpxyzsm_plot_count eq 7, put "%sm_ppt_7_name%"; );
$if setglobal sm_ppt_8_name  If(gpxyzsm_plot_count eq 8, put "%sm_ppt_8_name%"; );
$if setglobal sm_ppt_9_name  If(gpxyzsm_plot_count eq 9, put "%sm_ppt_9_name%"; );
put /;
$goto  skipppttitle

$label ppttitle_loop2
$if "%sm_loop2%"   == "no"                        put '"' /;
$if "%sm_loop2%"   == "0"                         put '"' /;
$if "%sm_loop2%"   == "no"                        $goto skipppttitle
$if "%sm_loop2%"   == "0"                         $goto skipppttitle
put ' ',%sm_loop2%.te(%sm_loop2%);
$if     setglobal sm_loop3                        $goto ppttitle_loop3
$if setglobal sm_ppt_1_name  If(gpxyzsm_plot_count eq 1, put "%sm_ppt_1_name%"; );
$if setglobal sm_ppt_2_name  If(gpxyzsm_plot_count eq 2, put "%sm_ppt_2_name%"; );
$if setglobal sm_ppt_3_name  If(gpxyzsm_plot_count eq 3, put "%sm_ppt_3_name%"; );
$if setglobal sm_ppt_4_name  If(gpxyzsm_plot_count eq 4, put "%sm_ppt_4_name%"; );
$if setglobal sm_ppt_5_name  If(gpxyzsm_plot_count eq 5, put "%sm_ppt_5_name%"; );
$if setglobal sm_ppt_6_name  If(gpxyzsm_plot_count eq 6, put "%sm_ppt_6_name%"; );
$if setglobal sm_ppt_7_name  If(gpxyzsm_plot_count eq 7, put "%sm_ppt_7_name%"; );
$if setglobal sm_ppt_8_name  If(gpxyzsm_plot_count eq 8, put "%sm_ppt_8_name%"; );
$if setglobal sm_ppt_9_name  If(gpxyzsm_plot_count eq 9, put "%sm_ppt_9_name%"; );
put /;
$goto  skipppttitle

$label ppttitle_loop3
$if "%sm_loop3%"   == "no"                        put '"' /;
$if "%sm_loop3%"   == "0"                         put '"' /;
$if "%sm_loop3%"   == "no"                        $goto skipppttitle
$if "%sm_loop3%"   == "0"                         $goto skipppttitle
put ' ',%sm_loop3%.te(%sm_loop3%);
$if     setglobal sm_loop4                        $goto ppttitle_loop4
$if setglobal sm_ppt_1_name  If(gpxyzsm_plot_count eq 1, put "%sm_ppt_1_name%"; );
$if setglobal sm_ppt_2_name  If(gpxyzsm_plot_count eq 2, put "%sm_ppt_2_name%"; );
$if setglobal sm_ppt_3_name  If(gpxyzsm_plot_count eq 3, put "%sm_ppt_3_name%"; );
$if setglobal sm_ppt_4_name  If(gpxyzsm_plot_count eq 4, put "%sm_ppt_4_name%"; );
$if setglobal sm_ppt_5_name  If(gpxyzsm_plot_count eq 5, put "%sm_ppt_5_name%"; );
$if setglobal sm_ppt_6_name  If(gpxyzsm_plot_count eq 6, put "%sm_ppt_6_name%"; );
$if setglobal sm_ppt_7_name  If(gpxyzsm_plot_count eq 7, put "%sm_ppt_7_name%"; );
$if setglobal sm_ppt_8_name  If(gpxyzsm_plot_count eq 8, put "%sm_ppt_8_name%"; );
$if setglobal sm_ppt_9_name  If(gpxyzsm_plot_count eq 9, put "%sm_ppt_9_name%"; );
put /;
$goto  skipppttitle

$label ppttitle_loop4
$if "%sm_loop4%"   == "no"                        put '"' /;
$if "%sm_loop4%"   == "0"                         put '"' /;
$if "%sm_loop4%"   == "no"                        $goto skipppttitle
$if "%sm_loop4%"   == "0"                         $goto skipppttitle
put ' ',%sm_loop4%.te(%sm_loop4%);
$if setglobal sm_ppt_1_name  If(gpxyzsm_plot_count eq 1, put "%sm_ppt_1_name%"; );
$if setglobal sm_ppt_2_name  If(gpxyzsm_plot_count eq 2, put "%sm_ppt_2_name%"; );
$if setglobal sm_ppt_3_name  If(gpxyzsm_plot_count eq 3, put "%sm_ppt_3_name%"; );
$if setglobal sm_ppt_4_name  If(gpxyzsm_plot_count eq 4, put "%sm_ppt_4_name%"; );
$if setglobal sm_ppt_5_name  If(gpxyzsm_plot_count eq 5, put "%sm_ppt_5_name%"; );
$if setglobal sm_ppt_6_name  If(gpxyzsm_plot_count eq 6, put "%sm_ppt_6_name%"; );
$if setglobal sm_ppt_7_name  If(gpxyzsm_plot_count eq 7, put "%sm_ppt_7_name%"; );
$if setglobal sm_ppt_8_name  If(gpxyzsm_plot_count eq 8, put "%sm_ppt_8_name%"; );
$if setglobal sm_ppt_9_name  If(gpxyzsm_plot_count eq 9, put "%sm_ppt_9_name%"; );
put /;
$goto  skipppttitle

$label skipppttitle

    );
PUTCLOSE;
execute 'sleep 1';

$label after_writing_ppt_file

put shademap_run;

$if not setglobal sm_ppt_2     $goto after_ppt_output_name_2
$if setglobal sm_ppt_2         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_2' /;
$if setglobal sm_ppt_2         $goto specify_winoptions
$label after_ppt_output_name_2

$if not setglobal sm_ppt_3     $goto after_ppt_output_name_3
$if setglobal sm_ppt_3         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_3' /;
$if setglobal sm_ppt_3         $goto specify_winoptions
$label after_ppt_output_name_3

$if not setglobal sm_ppt_4     $goto after_ppt_output_name_4
$if setglobal sm_ppt_4         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_4' /;
$if setglobal sm_ppt_4         $goto specify_winoptions
$label after_ppt_output_name_4

$if not setglobal sm_ppt_5     $goto after_ppt_output_name_5
$if setglobal sm_ppt_5         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_5' /;
$if setglobal sm_ppt_5         $goto specify_winoptions
$label after_ppt_output_name_5

$if not setglobal sm_ppt_6     $goto after_ppt_output_name_6
$if setglobal sm_ppt_6         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_6' /;
$if setglobal sm_ppt_6         $goto specify_winoptions
$label after_ppt_output_name_6

$if not setglobal sm_ppt_7     $goto after_ppt_output_name_7
$if setglobal sm_ppt_7         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_7' /;
$if setglobal sm_ppt_7         $goto specify_winoptions
$label after_ppt_output_name_7

$if not setglobal sm_ppt_8     $goto after_ppt_output_name_8
$if setglobal sm_ppt_8         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_8' /;
$if setglobal sm_ppt_8         $goto specify_winoptions
$label after_ppt_output_name_8

$if not setglobal sm_ppt_9     $goto after_ppt_output_name_9
$if setglobal sm_ppt_9         put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_9' /;
$if setglobal sm_ppt_9         $goto specify_winoptions
$label after_ppt_output_name_9

put 'start /w shademap %mapid% %mapid%_%data%.txt %mapid%_',gpxyzsm_plot_count:0:0,'_1';
putclose;

execute 'run_shademap.bat';
execute 'copy "%gams.scrdir%shademap.scr" "%mapid%.opt"';
execute 'sleep 1';
$goto  end_of_shademap


$label interactive_shademap

execute 'start shademap %mapid% %mapid%_%data%.txt';
execute 'copy "%gams.scrdir%shademap.scr" "%mapid%.opt"';
*execute 'start shademap %mapid% %mapid%_%data%.txt';
*$if exist "%gams.scrdir%%mapid%.scr" execute 'copy "%gams.scrdir%%mapid%.scr" %mapid%.opt';

$label end_of_shademap
