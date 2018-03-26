#!/bin/bash

# Global variables
SCRIPTNAME=$(basename $0)

EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

targetcrsname="etrs89"
reversedtf="false"
# betafile="/usr/share/proj/BWTA2017.gsb"
betafile="/usr/share/proj/BETA2007.gsb"

usage(){
	echo "$0 [-r] [-n nadgridsfile] [-v] infile.shp [outfile.shp]"
        echo " -r reverse transformation" 
        echo " -n nadgridsfile (default: /usr/share/proj/BETA2007.gsb)" 
        [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# Option -h (help) should always be there
# if you have an option argument to be parsed use ':' after option
while getopts ':rn:vh' OPTION ; do
        case $OPTION in
        v)        verbose=y
                ;;
        n)        betafile="$OPTARG"
                ;;
        r)        reversedtf="true"
                ;;
        h)        usage $EXIT_SUCCESS
                ;;
        \?)        echo "Unknown option \"-$OPTARG\"." >&2
                usage $EXIT_ERROR
                ;;
        :)        echo "Option \"-$OPTARG\" requires an argument." >&2
                usage $EXIT_ERROR
                ;;
        *)        echo "This should not habe been reached (bug in $0)..."
>&2
                usage $EXIT_BUG
                ;;
        esac
done

# Verbrauchte Argumente überspringen
shift $(( OPTIND - 1 ))

btaname=$(basename "$betafile" .gsb)

if [ ! -f "$betafile" ] ; then
	echo "grid tranformation file $betafile not found"
	exit 1
fi

fromsrs="+proj=tmerc +lat_0 =0 +lon_0=9 +x_0=3500000 +y_0=0 +k=1.000000 +ellps=bessel +units=m +nadgrids=$betafile +wktext " 
#"+EPSG:31467 +nadgrids=$betafile +wktext"
tosrs="EPSG:4258"

if [ "$reversedtf" == "true" ] ; then
    tmpsrs="$fromsrs"
    fromsrs="$tosrs"
    tosrs="$tmpsrs"
    targetcrsname="gk3"
fi

if [ -z "$1" ] ; then
	echo error: no input .shp given
	usage
	exit 1
else 
	if [ -z "$2" ] ; then
		targetshpfile="${1%.shp}_via_${btaname}_to_${targetcrsname}.shp"
	else
		targetshpfile="$2"
	fi
	echo "$tofile"
	if [ -e "$tofile" ] ; then
		echo "error: target exists"
		exit 1
	fi
fi


### Transformation mit ogr2ogr
ogr2ogr \
-s_srs \
"$fromsrs" \
-t_srs \
"$tosrs" \
-f "ESRI Shapefile" \
"$targetshpfile" \
"$1"
