#!/usr/bin/env bash


script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

scriptname=$(basename "${BASH_SOURCE[0]}")

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue

Usage: $scriptname -t target -v vulners -r recipient [-s stylesheet] [-f sender] [-I "0 0 1 * *"]

This script executes an Nmap scan using the vulners nse   script
It outputs an xml file and formats the result using a stylesheet 
when provided. Results are sent out using mail

Available options:

-h, --help          Print this help and exit

-i, --inventory     [Filepath] Accepts host file inventory each record is separated by \n.
                    does'nt work together with the -t parameter

-t, --target        [String] Accepts inidividual host to scan.
                    does'nt work together with the -i parameter

-v, --vulners       [Filepath] Accepts Vulners script path
                    ie: /usr/share/nmap/scripts/vulners.nse

-r, --recipient     [String] Accepts comma delimited recipient(s)
                    ie: user1@example.com,user2@example.com

-f, --from          [String] Sender Address
                    default: $HOSTNAME

-d, --destination   (optional) [Filepath] directory to store outputs.
                    default: /tmp

-I, --Install       (optional) [String] Accepts cron schedule expressions. Installs the script as a cron job
                    ie: "0 0 1 * *" (https://crontab.guru/#0_0_1_*_*)

EXAMPLES

  $scriptname -t 192.168.1.1 -v vulners.nse -r recipient@example.com -s ./nmap-bootstrap.xsl
  $scriptname -i inventory.txt -v /usr/share/nmap/scripts/vulners.nse -r recipient@example.com -f sender@example.com
  
EOF
  exit
}

quit(){
  die "Missing script arguments. see: [ $scriptname --help ]"
}


setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

err() {
  echo "${1-}" 1>&2;
}

success() {
  echo -e "${GREEN}${1-}${NOFORMAT}"
}

info() {
  echo -e "${BLUE}${1-}${NOFORMAT}"
}


die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  err "$msg"
  exit "$code"
}

parse_params() {

  i=""
  t=""
  v=""
  r=""
  f=${HOSTNAME}
  s=""
  d="/tmp"
  I=""

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -i | --inventory) shift
      i="${1-}"
    ;;
    -t | --target) shift
      t="${1-}"
    ;;
    -v | --vulners) shift
      v="${1-}"
    ;;
    -r | --recipient) shift
      r="${1-}"
    ;;
    -f | --from) shift
      [ -n "${1}" ] && f=${1}
    ;;
    -s | --stylesheet) shift
      s="${1-}"
    ;;
    -d | --destination) shift
      [ -n "${1}" ] && d=${1}
      info "Results will be stored in $d"
    ;;
    -I | --Install) shift
      I="${1-}"
      info "Installation parameter provided. Wont run scan this time"
    ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # Check if all required variables are set
  if ([ -n "${i}" ] && [ -n "${t}" ]) || [ -z "${v}" ] || [ -z "${r}" ]; then 
    quit
  fi

  return 0
}

setup_colors
parse_params "$@"

##Checks##
info "Running environment Checks"

if type nmap >/dev/null 2>&1; then
  success "Nmap check Passed"
else
  err "Error nmap is not installed."
  exit 1
fi

if type xsltproc >/dev/null 2>&1; then
  success "Xsltproc check Passed"
else
  err "Error xsltproc is not installed."
  exit 1
fi

if type mail >/dev/null 2>&1; then
  success "Mail check Passed"
else
  err "Error mail is not installed."
  exit 1
fi

##Parsing##
OUTPUT="$d/$(date +%Y-%m-%d_%H-%M-%S).nmap-result"


if [[ -n "${t}" ]]; then 
  scanner="nmap -sV -T5 --script $v --script-args mincvss=5.0 $t -v -oX $OUTPUT.xml 2>&1" 
  install="bash $script_dir/$scriptname --vulners $v --recipient $r --target $t --from $f --stylesheet $s 2>&1"
  targets=$t
else
  scanner="nmap -sV -T5 --script $v --script-args mincvss=5.0 -iL $i -v -oX $OUTPUT.xml 2>&1" 
  install="bash $script_dir/$scriptname --vulners $v --recipient $r --inventory $i --from $f --stylesheet $s 2>&1"
  targets=$(cat ${i} | tr '\n' ',')
fi

if [[ -n $s ]]; then
  formatter="xsltproc -o ${OUTPUT}.html ${s} ${OUTPUT}.xml"
else
  formatter="xsltproc ${OUTPUT}.xml -o ${OUTPUT}.html"
fi

#email 
_subject="\"${scriptname} - $(date)\""
_to=${r}

if [[ -n "${I}" ]]; then
  info "Installing Script as a cron job"
  echo "$I $USER $install" > /etc/cron.d/nmap-vulners
  if ! [ $? -eq 0 ]; then
    err "Installation Failed"
    exit 1
  fi

  mailer="echo \"${scriptname} was installed at ${HOSTNAME}\" | mail -a \"FROM:${f}\" -s \"${scriptname} - Installation\" ${r}"
  eval $mailer
  exit 0
fi

mailer="echo \"Scanned target(s): ${targets}\" | mail -A $OUTPUT.html -a \"FROM:${f}\" -s \"${scriptname} - Scan Report\" ${r}"

##Execution##
info "Scanning Target(s)"
info "CMD: ${YELLOW}${scanner}${NOFORMAT}"
message=$(eval $scanner)

if ! [ $? -eq 0 ]; then
  err "Error with running scan\n$command\n$message"
  exit 1
fi

info "Formatting Output"
info "CMD: ${YELLOW}${formatter}${NOFORMAT}"
message=$(eval $formatter)

if ! [ $? -eq 0 ]; then
  err "Error with formatting output\n$command\n$message"
  exit 1
fi

info "Mailing to Recipient(s)"
info "CMD: ${YELLOW}${mailer}${NOFORMAT}"
message=$(eval $mailer)

if ! [ $? -eq 0 ]; then
    err "Error with sending Mail\n$command\n$message"
    exit 1
fi

success "Run Completed"