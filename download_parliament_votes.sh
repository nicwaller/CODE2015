#!/bin/bash
# Download all the parliamentary votes!!

CHAMBER_VOTE_RESOURCE='http://www.parl.gc.ca/HouseChamberBusiness/Chambervotelist.aspx'
CHAMBER_VOTE_DETAIL_RESOURCE='http://www.parl.gc.ca/HouseChamberBusiness/Chambervotedetail.aspx'


function download_vote_details () {
	mkdir -p data
	REGEX="parl([0-9]+)_sess([0-9]+).xml"
	for i in $( ls data/parl??_sess?.xml ); do
		[[ $i =~ $REGEX ]]
		PARL="${BASH_REMATCH[1]}"
		SESS="${BASH_REMATCH[2]}"

		echo "Parsing vote list ${i}"
		for VOTE in $(xpath $i '/Votes/Vote/@number' 2>/dev/null | xargs -n1 | cut -d= -f2) ; do
			URL="${CHAMBER_VOTE_DETAIL_RESOURCE}?Language=E&Mode=1&Parl=${PARL}&Ses=${SESS}&FltrParl=${PARL}&FltrSes=${SESS}&vote=${VOTE}&xml=True"

			OUTPUT="data/parl${PARL}_sess${SESS}_vote${VOTE}.xml"
			if [ ! -f "${OUTPUT}" ] ; then
				echo "${URL}"
				curl --output "${OUTPUT}" "${URL}"
			fi
		done
	done
	#VOTE_NUMBERS=$(xpath parl39_sess1.xml '/Votes/Vote/@number' 2>/dev/null | xargs -n1 | cut -d= -f2)
	#for i in $( ls ); do
	#        echo item: $i
	#    done
}

function download_votes () {
	mkdir -p data
	N_PARLIAMENT="$1"
	N_SESSION="$2"
	OUTPUT="data/parl${N_PARLIAMENT}_sess${N_SESSION}.xml"
	if [ ! -f "${OUTPUT}" ] ; then
		URL="${CHAMBER_VOTE_RESOURCE}?Language=E&Parl=${N_PARLIAMENT}&Ses=${N_SESSION}&xml=True"
		echo "${URL}"
		curl --output "${OUTPUT}" "${URL}"
	fi
}

function main () {
	download_votes 39 1
	download_votes 39 2
	download_votes 40 1
	download_votes 40 2
	download_votes 40 3
	download_votes 41 1
	download_votes 41 2

	download_vote_details
}

main

#39.1
#39.2
#40.1
#40.2
#40.3
#41.1
#41.2

#Language=E&Parl=41&Ses=1&xml=True
#http://www.parl.gc.ca/HouseChamberBusiness/Chambervotelist.aspx?Language=E&Parl=41&Ses=1&xml=True
#Language=E&Mode=1&Parl=41&Ses=1&FltrParl=41&FltrSes=1&VoteType=0&AgreedTo=True&Negatived=True&Tie=True&Page=1&xml=True&SchemaVersion=1.0
#http://www.parl.gc.ca/HouseChamberBusiness/Chambervotelist.aspx?Language=E&Mode=1&Parl=41&Ses=1&FltrParl=41&FltrSes=1&VoteType=0&AgreedTo=True&Negatived=True&Tie=True&Page=1&xml=True&SchemaVersion=1.0
