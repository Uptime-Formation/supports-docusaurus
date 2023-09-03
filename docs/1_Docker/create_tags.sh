counter=/tmp/counter
while read f ; do
  w=$(cat $counter)
  [[ -z $w ]] && w=25
  id=$( echo $f| tr " " "-" ); 
  file_name=$id.md
  [[ -s $f ]] && continue; 
  echo touch $id.md; 
  i=$( echo $file_name| sed -r "s/^([0-9]\-[0-9]*).*$/\1/"|tr "-" "."); 
  l=$( echo $file_name | sed -r "s/^[0-9]\-[0-9]*-(.*).md$/\1/"|tr "-" " "); 
  cat << EOF > $file_name 
---
title: $l
pre: "<b>$i </b>"
weight: $w
---

## Objectifs pédagogiques
EOF
let $(( w++ ))
echo -n $w > $counter
  
done 
