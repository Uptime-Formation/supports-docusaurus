#!/bin/bash

which pdfnice &>/dev/null || { echo "!!! Missing pdfnice! Please use the bin/pdfnice script at the root of the project" : exit 1 ; }

#set -e 


APP_PATH=$( cd $(dirname $0) && pwd )
TMPDIR=$(cd "${APP_PATH}" && mkdir -p _pdf && echo "${APP_PATH}/_pdf")

# Identify the folder containing the slides
cd "$APP_PATH"

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
    FORMATION_NAME=${PROJECTS_DIRNAME[$FORMATION_NUM]}
    FORMATION_DIR=${PROJECTS_FULLPATH[$FORMATION_NUM]}
done


PDF_NAME="$( echo ${FORMATION_NAME} | sed -r "s/^[0-9]*_//").pdf"


# Copy markdown files to tmp directory and patch images paths 

# [[ -d "${TMPDIR}" ]]  && rm -rf "${TMPDIR}" && mkdir "${TMPDIR}"

cp "${FORMATION_DIR}"/*md "${TMPDIR}/"
cd "${TMPDIR}"
sed -i -r "s=/img/=../../static/img/=" *md

# Loop through files and convert them to PDF
DATE=$(date +"%d/%m/%Y")
LIST=()
for file in *\.md; do
  content=""
  pdfname="${file/.md/}.pdf"
  LIST+=("$pdfname")
  [[ -f "$pdfname" ]] && continue
  logname="${file/.md/}.log"
  sed -i -r "s=%DATE%=$DATE=" $file
  # Set content
  m=0;
  length=$(wc -l "$file" | awk '{print $1}')
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

  title=$( cat "$file" | grep '^#' | head -n 1| sed 's/^# //')
  cat <<EOF > $file
---
title: "$title"
author: [PLB]
date: "$DATE"
titlepage: true
titlepage-text-color: "3366ff"
titlepage-rule-color: "3366ff"
titlepage-rule-height: 4
book: true
...
EOF
  echo -e "$content" >> "$file"
  echo "Convert "$file" to $pdfname"
  ~/bin/pdfnice "$file" "$pdfname" 2>"$logname"
  [[ $? -ne 0 ]] && {

      echo "An error occured with file $file."
      read -e -p "Want to see $logname ? [Y/n]" REPLY
      [[ "N" != ${REPLY^^} ]] && vim $logname
      exit 1
  }
done

# Finish by creating the PDF file
echo Uniting pdffiles
pdfunite ${LIST[@]} "${PDF_NAME}"
mv ${PDF_NAME} "${APP_PATH}"
echo "File available : ${APP_PATH}/${PDF_NAME}"

# Cleanup the temp dir
cd "${APP_PATH}"
# echo "Cleaning up tmpdir $TMPDIR"
# rm -rf "${TMPDIR}"
