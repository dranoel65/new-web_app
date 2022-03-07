echo "*************************************"
LANG="en_US.utf-8"
cd ~/app-build

# Variables
seed=$(( ( RANDOM % 1000 )  + 1 ))
site=$1
bucket=$2

# Build Folder
cd ~/app-build

mkdir -p build-dev/css/bootstrap

echo "Copiando archivos"
echo

cp index.html build-dev/index.html
cp main.dart.js build-dev/main.dart.js
cp -R assets build-dev/assets
cp -R js build-dev/js
cp css/*.css build-dev/css/
cp css/bootstrap/*.css build-dev/css/bootstrap/

find build-dev/ -name "*.js" -exec sed -i "s/http:\/\/localhost:3070/https:\/\/$site/g" {} \;
find build-dev/ -name "*.html" -exec sed -i "s/ramdomTest/bust=$seed/g" {} \;

cd build-dev
echo -n "Gzip files before upload to S3 ..."


echo
echo " Comprimiendo"
echo

gzip index.html
gzip main.dart.js

find js -name "*.js" -exec gzip {} \;
find css -name "*.css" -exec gzip {} \;
find assets -name "*.svg" -exec gzip {} \;

echo " Done Zipping."
echo
echo " Optimizando."
echo

find assets -name "*.png" -exec optipng {} \;
find assets -name "*.jpg" -exec jpegoptim --strip-all {} \;

echo "path"
pwd

s3cmdOpt="-c /home/heber/webstorm/s3cfg -P"

s3cmd $s3cmdOpt --exclude="*.gz" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "+365 days"`" --add-header="Cache-Control:public, max-age=28648148" sync assets/ s3://$bucket/assets/
#s3cmd $s3cmdOpt sync sounds/ s3://$bucket/sounds/
//s3cmd $s3cmdOpt --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "+365 days"`" --add-header="Cache-Control:public, max-age=28648148" sync font/ s3://$bucket/font/
#s3cmd $s3cmdOpt sync lang/ s3://$bucket/lang/


s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "-365 days"`" --add-header="Cache-Control:public, max-age=0" --mime-type="text/html; charset=utf-8" put index.html.gz s3://$bucket/index.html
s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "-365 days"`" --add-header="Cache-Control:public, max-age=0" --mime-type="application/javascript; charset=utf-8" put main.dart.js.gz s3://$bucket/main.dart.js


echo
echo
echo " START Uploading."
echo
echo

find css -iname "*.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "+365 days"`" --add-header="Cache-Control:public, max-age=28648148" --mime-type="text/css; charset=utf-8" put {}.gz s3://$bucket/{}

find js -iname "*.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "+365 days"`" --add-header="Cache-Control:public, max-age=28648148" --mime-type="application/javascript; charset=utf-8" put {}.gz s3://$bucket/{}

find assets -iname "*.svg.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Expires:`date -u +"%a, %d %b %Y %H:%M:%S GMT" --date "+365 days"`" --add-header="Cache-Control:public, max-age=28648148" --mime-type="image/svg+xml" put {}.gz s3://$bucket/{}
#
# find img -iname "*.png.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Cache-Control:public, max-age=28648148" --mime-type="image/png" put {}.gz s3://$bucket/{}
#
# find img -iname "*.jpg.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Cache-Control:public, max-age=28648148" --mime-type="image/jpeg" put {}.gz s3://$bucket/{}
#
# find img -iname "*.gif.gz" | sed -e "s/.gz//g" | xargs -i s3cmd $s3cmdOpt --add-header="Content-Encoding:gzip" --add-header="Cache-Control:public, max-age=28648148" --mime-type="image/gif" put {}.gz s3://$bucket/{}



cd ..
# rm -R build-dev

echo
echo
echo " DONE Uploading."

#para actualizar el expire
#aws s3 cp s3://$bucket s3://$bucket --recursive  --acl public-read  --metadata-directive REPLACE --cache-control max-age=2864
