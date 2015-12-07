function error_exit
{
  echo "$1" 1>&2
  exit 1
}

if [ -z "$1" ]; then
    echo "No config supplied.  Usage: ./create_tz_db.sh /data/valhalla/mjolnir/conf/valhalla.json"
    exit 1
fi

if  ! which jq >/dev/null; then
    echo "jq not found which is required.  Please install via:  sudo apt-get install jq"
    exit 1
fi

if  ! which spatialite >/dev/null; then
    echo "spatialite not found which is required.  Please install via:  sudo apt-get install spatialite-bin"
    exit 1
fi

rm -rf world
rm -f ./tz_world_mp.zip

config=$1
if [ ! -f $config ]; then
    echo "Config file not found $config"
    exit 1
fi
tz_file=$(jq -r '.mjolnir.timezone' $config)
if [ ! -d $(dirname $tz_file) ]; then
    echo "Timezone directory not found $(dirname $tz_file)"
    exit 1
fi
rm -f $tz_file
url="http://efele.net/maps/tz/world/tz_world_mp.zip"
wget $url || error_exit "wget failed for " $url
unzip ./tz_world_mp.zip || error_exit "unzip failed"
spatialite_tool -i -shp ./world/tz_world_mp -d $tz_file -t tz_world -s 4326 -g geom -c UTF8 || error_exit "spatialite_tool import failed"
spatialite $tz_file "SELECT CreateSpatialIndex('tz_world', 'geom');" || error_exit "SpatialIndex failed" 

rm -rf world
rm -f ./tz_world_mp.zip
