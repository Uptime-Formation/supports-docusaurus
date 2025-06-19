#!/bin/bash

APP_PATH=$( cd $(dirname $0) && pwd )

cd "$APP_PATH"

set -e 

rm -f _pdf/*md 
cp *md _pdf/
cd _pdf
# ls ../../../static
sed -i -r "s=(../../static/)=../\1=" *md
#grep static *md

DATE=$(date +"%d/%m/%Y")
LIST=()
for file in *\.md; do
  pdfname=${file/.md/}.pdf
  if [[ "$file" == "01-Introduction.md" ]]; then
    sed -i -r "s=%DATE%=$DATE=" $file
  else
    content=$(cat $file )
    title=$( cat $file | grep '^#' | head -n 1| sed 's/^# //')
    cat <<EOF > $file
---
title: "$title"
author: [Uptime Formation]
date: "$DATE"
keywords: [KVM, Devops]
titlepage: true
titlepage-text-color: "3366ff"
titlepage-rule-color: "3366ff"
titlepage-rule-height: 4
book: true
...
EOF
    echo "$content" >> $file
  fi
  LIST+=($pdfname)
  echo "Convert $file to $pdfname"
  ~/bin/pdfnice $file $pdfname
done

echo Uniting pdffiles
pdfunite ${LIST[@]} kvm.pdf


# ~/bin/pdfnice *.md Uptime-formation-kvm.pdf

#set -e 
#rm -f "${APP_PATH}/_pdf/*md"
#cp "${APP_PATH}/"*md "${APP_PATH}/_pdf/"
#sed -i "s=/img/=../../static/img=" "${APP_PATH}/_pdf/"*md
#~/bin/pdfnice "${APP_PATH}/_pdf/"*.md ${APP_PATH}/out.pdf
