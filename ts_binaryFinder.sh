IFS=':'; \
for i in $DEPLOY_PATH; \
   do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > commands.txt

