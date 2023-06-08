IFS=':'; \
for i in $DEPLOY_PATH; \
   do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > commands.txt

for i in $DEPLOY_BINS; \
   do echo "$i"; done >> commands.txt

touch envvar.txt envpath.txt
env | grep DEPLOY_ENVVAR_ > envvar.txt
env | grep DEPLOY_ENVPATH_ > envpath.txt


