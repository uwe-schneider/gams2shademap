* +++++++++++++++++++++++++++++++++++++++++ *
* Creation of new maps for GAMS to Shademap *
*           Uwe A. Schneider                *
* +++++++++++++++++++++++++++++++++++++++++ *

* Select Name(s) of Maps
* For each map name, place a <map name>_MIF.GIS and <map name>_MID.GIS file in a .\gis subdirectory
SETS
 mapname
  /
*  gadm36_ESP_0
*  gadm36_ESP_1
*  gadm36_ESP_2
*  gadm36_ESP_3
*  gadm36_ESP_4
*  gadm36_DEU
   worldcountries
  /
;



FILE makemid /2_make_mid.gms/; PUT  makemid;
makemid.tW=0; makemid.LW=0; makemid.NW=0; makemid.ND=0;

* The following code identifies duplicates in columns
* If duplicates exist, then the column is not used

SET Columns /column1*column20/;
*SET Columns /column1*column5/;

PUT "$onecho > analyze_mid.awk" /;
PUT 'BEGIN { FS = ","; column_for_print = 0;' /;
LOOP(Columns, PUT "usecol_",ord(Columns)," = 1;"/; ); PUT "}" /;
PUT "{" /;
LOOP(Columns, PUT "if($",ord(Columns)," != ",'""',") column_",ord(Columns),"[$",ord(Columns),"]++;" /; ); PUT /;
LOOP(Columns, PUT "if(column_",ord(Columns),"[$",ord(Columns),"] > 1.5) usecol_",ord(Columns)," = 0;  " /; ); PUT /;
PUT "}" / "END {" /;
LOOP(Columns, PUT "if(usecol_",ord(Columns)," > 0.5 && column_for_print < 0.8) column_for_print = ",ord(Columns),";" /; ); PUT /;
PUT 'print "BEGIN { FS = \",\" }";' /;
PUT 'print "{print $" column_for_print ";}";' /;
PUT "}" /;
PUT "$offecho" / /;

PUT "$onecho > prepare_set.awk" /;
PUT 'BEGIN { FS = ","; column_for_print = 0;' /;
LOOP(Columns, PUT "usecol_",ord(Columns)," = 1;"/; ); PUT "}" /;
PUT "{" /;
LOOP(Columns, PUT "if($",ord(Columns)," != ",'""',") column_",ord(Columns),"[$",ord(Columns),"]++;" /; ); PUT /;
LOOP(Columns, PUT "if(column_",ord(Columns),"[$",ord(Columns),"] > 1.5) usecol_",ord(Columns)," = 0;  " /; ); PUT /;
PUT "}" / "END {" /;
LOOP(Columns, PUT "if(usecol_",ord(Columns)," > 0.5 && column_for_print < 0.8) column_for_print = ",ord(Columns),";" /; ); PUT /;


PUT 'print "BEGIN { FS = \",\"; linenumber = 1; }";' /;
PUT 'print "# Print the first field of each line";' /;
PUT 'print "      {";' /;
PUT 'print "    if (linenumber < 2) print \"SET\";";' /;
PUT 'print "    if (linenumber < 2) printf \"%s\", FILENAME;";' /;
PUT 'print "    if (linenumber < 2) print \"_sm  Set of\",FILENAME,\"Region Names Needed for ShadeMap (SM)\";";' /;
PUT 'print "    if (linenumber < 2) print \"  /\";";' /;
PUT 'print "    linenumber = linenumber + 1;";' /;
PUT 'print "    if (linenumber > 1) print \"  \",$" column_for_print ";";' /;
PUT 'print "      }";' /;
PUT 'print "END   { print \"  /;\"; }";' /;
PUT "}" /;
PUT "$offecho" / /;


$onput
$onecho >process_mif.awk
# Print 7 lines
BEGIN {regionnumber = 0;
       print "* This file contains the X Y coordinates for a map";
       print "* The first 7 lines in this file are ignored";
       print "* Each region is followed by the number of polygons";
       print "* The line after contains the number of points on a polygon";
       print "* https://www.copsmodels.com/shademap.htm";
       print "* https://github.com/uwe-schneider/gams2shademap/wiki#gams-to-shademap";
       print " ";
      }
# Print all lines starting with the lowest line, which contains the field "Region"
# After the coordinates of the first region have been printed, add two lines ("brush" and "pen")
# Then proceed with the other regions
{
    if (tolower($1) == "region") regionnumber = regionnumber + 1;
    if (tolower($1) == "region" && regionnumber > 1) print "brush";
    if (tolower($1) == "region" && regionnumber > 1) print "pen";
    if (tolower($1) == "region" && regionnumber > 0) print "REGION ", $2;
    if (tolower($1) != "region" && tolower($1) != "brush" && tolower($1) != "pen" && regionnumber > 0) print $1,$2;
}
$offecho
$offput
PUTCLOSE;


Execute "gams 2_make_mid.gms ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1  cerr=5  pw=120";


FILE makeawkrun /3_run_integration.gms/; PUT  makeawkrun;
makeawkrun.lw=0;makeawkrun.tw=0;makeawkrun.nw=0;makeawkrun.nd=0;

LOOP(mapname,

 PUT "$call awk -f analyze_mid.awk .\gis\",mapname.TL,"_mid.gis >process_mid.awk" /;
 PUT "$call awk -f prepare_set.awk .\gis\",mapname.TL,"_mid.gis >process_set.awk" /;
 PUT "$call awk -f process_mif.awk .\GIS\",mapname.tl,"_mif.gis > %gams.sysdir%gislib\",mapname.tl,".mif" /;
 PUT "$call awk -f process_mid.awk .\GIS\",mapname.tl,"_mid.gis > %gams.sysdir%gislib\",mapname.tl,".mid" /;
 PUT "$call copy .\GIS\",mapname.tl,"_mid.gis ",mapname.tl /;
 PUT "$call awk -f process_set.awk ",mapname.tl," > ",mapname.tl,"_set.gms" /;
 PUT "$call copy ",mapname.tl,"_set.gms %gams.sysdir%gislib\",mapname.tl,"_set.gms" /;
 PUT "$call del ",mapname.tl /;
    );
 PUT /;

LOOP(mapname,

PUT 'File ',mapname.tl,'_map_gamsgis /"%gams.sysdir%gislib\',mapname.tl,'_sm.gms"/;'/;
PUT 'Put  ',mapname.tl,'_map_gamsgis;'/;

PUT mapname.tl,'_map_gamsgis.lw=0;'/;
PUT mapname.tl,'_map_gamsgis.tw=0;'/;
PUT mapname.tl,'_map_gamsgis.nw=0;'/;
PUT mapname.tl,'_map_gamsgis.nd=0;'//;

PUT '$include ',mapname.tl,'_set.gms' /;
PUT "PUT 'SET ",mapname.tl,"_r /",mapname.tl,"_1*",mapname.tl,"_',card(",mapname.tl,"_sm),'/;'/;" /;
PUT "PUT 'SET ",mapname.tl,"_map(",mapname.tl,"_r,*)' /;"/;

PUT "PUT ' /' /;" /;
PUT "LOOP(",mapname.tl,"_sm," /;
PUT " PUT '  ",mapname.tl,"_',ord(",mapname.tl,"_sm),'.",'"',"',",mapname.tl,"_sm.tl,'",'"',"' /;" /;
PUT "    );" /;
PUT "PUT ' /;' /;" /;

PUT //;

    );
PUTCLOSE;


Execute "gams 3_run_integration.gms ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1  cerr=5  pw=120";


File showmaps /4_showmaps.gms/; Put  showmaps;
showmaps.lw=0;showmaps.tw=0;showmaps.nw=0;showmaps.nd=0;

LOOP(mapname,
PUT "$include ",mapname.tl,"_set.gms" /;
PUT "Parameter plot",mapname.tl,"_map(",mapname.tl,"_sm) Shade Values for the Map of ",mapname.tl,";" /;
PUT "plot",mapname.tl,"_map(",mapname.tl,"_sm) = uniform(0.5,1);" /;
PUT "$setglobal sm_LegendPos ",'"10 70"',"" /;
PUT "$libinclude shademap ",mapname.tl," plot",mapname.tl,"_map" /;
    );
PUTCLOSE;

Execute "sleep 2";

EXECUTE "gams  4_showmaps.gms  ide=%gams.ide% lo=%gams.lo% errorlog=%gams.errorlog% errmsg=1  cerr=5  pw=120";

Execute "sleep 1";

Execute "del *.lst";
Execute "del *.lxi";
Execute "del *.~*";
Execute "del *.log";
Execute "del *.scr";
Execute "del *.put";
Execute "del *.mif";
Execute "del *.mid";




















