#!/bin/bash

which pdfnice &>/dev/null || { echo "!!! Missing pdfnice! Please use the bin/pdfnice script at the root of the project" : exit 1 ; }

#set -e

AUTHOR="Oxiane Institut"
LOGO="/home/alban/Documents/projets/RackFlow/80-99 Formation/supports-docusaurus/docs/assets/logos/logo-oxiane.jpg"
PAGE_DE_GARDE="00000000_Page_de_garde.md"

APP_PATH=$( cd $(dirname $0) && pwd )
TMPDIR=$(cd "${APP_PATH}" && mkdir -p _pdf && echo "${APP_PATH}/_pdf")

# Identify the folder containing the slides
cd "$APP_PATH"

read -e -p "Using Author $AUTHOR. OK?"

# Read all the projects in arrays
declare -a PROJECTS_FULLPATH
declare -a PROJECTS_DIRNAME
while read file ; do
    PROJECTS_FULLPATH+=("${file}")
    PROJECTS_DIRNAME+=("$(basename "${file}")")
done <<< $(find ~+ -maxdepth 1 -type d -name "[0-9]*" | sort -d)

# Select a valid project
echo -e "# PROJECT SELECTION\n"
for i in ${!PROJECTS_DIRNAME[@]}; do
    echo "$i - ${PROJECTS_DIRNAME[$i]}"
done
while [[ -z "$FORMATION_NAME" ]]; do
    echo -n "Please choose a project [0...n]:"
    read -e -p ": " FORMATION_NUM
    [[ $FORMATION_NUM -gt 0 ]] || continue
    FORMATION_NAME=$( echo ${PROJECTS_DIRNAME[$FORMATION_NUM]}  | sed -r "s/^[0-9]*_//" | tr "_-" "  ")
    FORMATION_DIR=${PROJECTS_FULLPATH[$FORMATION_NUM]}
done


PDF_NAME="${FORMATION_NAME}.pdf"


# Copy markdown files to tmp directory and patch images paths

read -e -n 1 -p "Do you want to clear cache? [Y/n]: "
REPLY=${REPLY:-Y}
[[ "N" != ${REPLY^^} ]] && {
  [[ -d "${TMPDIR}" ]]  && rm -rf "${TMPDIR}" && mkdir "${TMPDIR}"
}

cp "${FORMATION_DIR}"/*md "${TMPDIR}/"
cd "${TMPDIR}"
sed -i -r 's="/img/="../../static/img/=' *md

# Create a first page with logo
cat <<GARDE > "$PAGE_DE_GARDE"
---
title:  "$FORMATION_NAME"
weight: 000
author: [$AUTHOR]
keywords: [Kubernetes, Devops]
logo-width: 5cm
titlepage-logo: "$LOGO"
titlepage: true
titlepage-text-color: "1e53aa"
titlepage-rule-color: "1e53aa"
titlepage-rule-height: 4
---
GARDE

# Loop through files and convert them to PDF
DATE=$(date +"%d/%m/%Y")
NTH_PAGE=0
for file in *\.md; do

  content=""
  pdfname="${file/.md/}.pdf"
  LIST+=("$pdfname")
  logname="${file/.md/}.log"
  sed -i -r "s=%DATE%=$DATE=" $file
  is_first_page=$NTH_PAGE
  NTH_PAGE=1
  [[ -f "$pdfname" ]] && continue

  if [[ 0 -eq $is_first_page ]]; then
    content=$(cat $file)
  else

    # Set content
    m=0;
    length=$(wc -l "$file" | awk '{print $1}')
    # This removes the standard headers
    for i in $(seq 1 $length);
      do line=$( sed -n ${i}p $file);
        if [[ "$line" =~ ^--- && $m -lt 2 ]] ;
          then m=$(( m + 1 ));
        elif [[ $m -lt 2 ]];
          then continue;
        else
          content="$content\n$line";
       fi;
      done
    title=$( cat "$file" | grep '^#' | head -n 1| sed 's/^#\+ //')
    cat <<EOF > $file
---
title: "$title"
author: ["$AUTHOR"]
date: "$DATE"
titlepage-text-color: "1e53aa"
titlepage-rule-color: "1e53aa"
titlepage-rule-height: 4
titlepage: true
...
EOF
    echo -e "$content" >> "$file"
  fi

  echo "Convert "$file" to $pdfname"
  ~/bin/pdfnice "$file" "$pdfname" 2>"$logname"
  [[ $? -ne 0 ]] && {

      echo "An error occured with file $file."
      read -e -p "Want to see $logname ? [Y/n]" REPLY
      [[ "N" != ${REPLY^^} ]] && vim $logname
      read -e -p "Do you want to exit? [y/N]" PANIC
      [[ "Y" == ${PANIC^^} ]] && exit 1
  }
done

## Build the PDF file
echo Uniting pdffiles
pdfunite ${LIST[@]} "${PDF_NAME}"
mv "${PDF_NAME}" "${APP_PATH}"
echo "File available : ${APP_PATH}/${PDF_NAME}"

