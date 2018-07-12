IFS=':'; \
for i in $PATH; \
   do test -d "$i" && find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done >> commands.txt

