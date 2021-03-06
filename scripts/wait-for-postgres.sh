#!/bin/sh

main() {
  usage() { echo "Usage: $0 [-d <string*>] [-t <string*>] [-u <string*>] [-p <string*>] [-h <string>] [-m <number>]" 1>&2; exit 1; }

  while getopts ":h:d:t:u:p:m:" o; do
      case "${o}" in
          u)
            u=${OPTARG}
            ;;
          p)
            p=${OPTARG}
            ;;
          d)
            d=${OPTARG}
            ;;
          t)
            t=${OPTARG}
            ;;
          h)
            h=${OPTARG}
            ;;
          m)
            m=${OPTARG}
            ;;
      esac
  done
  shift $((OPTIND-1))

  if [ -z "${d}" ]; then
    echo 'Missing flag "-d", please provide a database name.'
    usage
  fi

  if [ -z "${t}" ]; then
    echo 'Missing flag "-t", please provide a table name.'
    usage
  fi
  if [ -z "${u}" ]; then
    echo 'Missing flag "-u", please provide a username.'
    usage
  fi
  if [ -z "${p}" ]; then
    echo 'Missing flag "-p", please provide a password.'
    usage
  fi

  if [ -z "${h}" ]; then
    h="localhost"
  fi

  if [ -z "${m}" ]; then
    m="30"
  fi

  counter=0;
  export PGPASSWORD=$p
  until psql -q -h $h -U $d -d $t -c '\l'; do
    echo >&2 "$(date +%I:%M:%S%p) Postgres is unavailable."
    counter=$(( counter + 1 ))

    if [ $counter -ge $m ]; then
      echo "Max tries of $m has been surpassed with no successful connection. Exiting."
      exit 1
    else
      sleep 1
    fi
  done
  echo >&2 "$(date +%I:%M:%S%p) Postgres is now available."
}

main "$@"
