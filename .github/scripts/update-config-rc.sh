#!/bin/bash

lasttag="1"
function repoHasRC {
  # Get tag last value
  org="ivvorg"
  repo=$1
  pack=$2
  stackfile="./airs-config-sync/stacks/$pack/stack.yml"
  if [ ! -f "$stackfile"  ]; then
	    echo "File $stackfile not found "
    exit 1
  fi

  echo "repo: $repo" 
  echo "pack: $pack" 

  tagvalue=""
  header="Accept: application/vnd.github+json"
  repo_full_name="https://api.github.com/repos/${org}/${repo}/tags"
  TAGS=$(curl -s "$repo_full_name" | jq -r '.[].name')
  echo "TAGS: $TAGS" 
  # Filter tags with the specified prefix and postfix
  TAG_PREFIX="v0."
  TAG_POSTFIX="-rc"
  tagvalue=$(echo "$TAGS" | grep "^$TAG_PREFIX.*$TAG_POSTFIX$")
  echo "tagvalue: $tagvalue" 

  if [ -z "$tagvalue" ]; then
    echo "Last release candidate tag for repo github.com/${org}/${repo} not found."
    exit 1
  fi

  echo "Last release candidate tag for repo github.com/${org}/${repo} is $tagvalue"
  # Remove prefix 'v0.' and postfix '.1*-rc'
  strdate=$(echo $tagvalue | sed -n 's/^v0.\([0-9]\{12\}\).*/\1/p')

  # Print the result
  echo "The last rc tag date is: $strdate"
  reptag="created"

  lasttag="1"
  pfound=0
  while read -r line; do
    i=$((i+1))
    if [ $pfound -eq 0 ]; then 
      if [[ $line =~ "pack: $pack" ]]; then
  	pfound=1	
      fi 
    else
       if [[ $line =~ "$reptag:" ]]; then
         # Extract the date using grep and sed
         curstrdate=$(echo $line | awk '{print $2}')
         curdt=$(date -d "${curstrdate:0:8} ${curstrdate:8:2}:${curstrdate:10:2}" +"%s")
         newdt=$(date -d "${strdate:0:8} ${strdate:8:2}:${strdate:10:2}" +"%s")
         if [ "$newdt" -gt "$curdt" ]; then 
           lasttag="$strdate"
           break
         fi
         break
       fi
    fi
  done < ${stackfile}
}

function updateSync {

  reptag="created"
  pack=$1
  tagvalue=$2
  stackfile="./airs-config-sync/stacks/$pack/stack.yml"
  if [ ! -f "$stackfile"  ]
  then
    echo "File $stackfile not found "
    exit 1
  fi

  echo "update tagvalue: $tagvalue"
  packfound=0
  while read -r line; do
    if [ $packfound -eq 0 ]; then 
     if [[ $line =~ "pack: $pack" ]]; then
  	packfound=1	
     fi 
    else
       if [[ $line =~ "$reptag:" ]]; then
         echo "found create:"
         sed -i "${i}s/.*$reptag.*/      $reptag: $tagvalue/" ${stackfile}
         echo "replaced with $reptag: $tagvalue in file $stackfile"
         break
       fi
    fi
  done < ${stackfile}
}

#stack="rc"
#stackfile="./airs-config-sync/stacks/$stack/stack.yml"
#if [ ! -f "$stackfile"  ]
#then
#    echo "File $stackfile not found "
#    exit 1
#fi
#bp3tag=$(repoHasRC "airs-bp3" "bp3")
#if [[ $bp3tag == "1" ]]; then
#    echo "New rc tag for airs-bp3 does not exist"
#    exit 1
#fi
#botag=$(repoHasRC "airc-backoffice2" "backoffice2")
#if [[ $botag == "1" ]]; then
#    echo "New rc tag for airc-backoffice2 does not exist"
#    exit 1
#fi
#rportaltag=$(repoHasRC "web-portals" "resellerportal")
#if [[ $portaltag == "1" ]]; then
#    echo "New rc tag for resellerportal does not exist"
#    exit 1
#fi
#pportaltag=$(repoHasRC "web-portals" "paymentsportal")
#if [[ $portaltag == "1" ]]; then
#    echo "New rc tag for paymentsportal does not exist"
#    exit 1
#fi

#updateSync "bp3", $bp3tag
#updateSync "backoffice2", $botag
#updateSync "resellerportal", $rportaltag
#updateSync "paymentsportal", $pportaltag

pack="public-tr"
repo="public-test-repo" 
repoHasRC $repo $pack

echo "prepotag: $lasttag"

if [[ $lasttag == "1" ]]; then
    echo "New rc tag for paymentsportal does not exist"
    exit 1
else
    echo "New rc tag $lasttag"
fi

updateSync $pack $lasttag


