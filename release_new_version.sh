export buildDate=`date +%Y%m%d`

# cache all released images:
sed '/command/d' menus/cache_raw.sh > menus/cache_raw_1.sh
sed 's/=//g' menus/cache_raw_1.sh > menus/cache.sh

#tagging release
echo "tagging this release as ${buildDate}"
git tag buildDate
git push origin --tags