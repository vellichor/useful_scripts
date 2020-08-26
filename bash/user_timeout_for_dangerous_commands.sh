#!/bin/bash

FORCE="" # can override warnings and confirmations with -f

# pull off flag args to override anything set in env
POS_ARGS="" # hold positional arguments here.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f)
      shift
      FORCE=1
      echo "WARNING: this script will now run without confirmation"
      ;;
    *)
      # not part of a flag pair. interpret this as a positional.
      POS_ARGS="${POS_ARGS} $1"
      shift
      ;;
  esac
done
# reset args to the positional args list
set -- $POS_ARGS

user_timeout() {
  wait_seconds=$1
  prompt=$2
  confirm_required=$3 # 0 if unset, confirm is not required
  # -f/force can cause us to skip this entire thing.
  if [[ ! $FORCE ]]; then
    echo "$prompt"
    if [[ $confirm_required ]]; then
      echo "To confirm, press y"
      echo "To suppress this warning in the future, use -f"
    else
      echo "Press ^C to cancel this operation"
    fi
    for i in $(seq 1 $wait_seconds); do
      echo -n "."
      if [[ $confirm_required ]]; then
        # wait for user input
        read -n1 -s -t 1 chr
        if [[ $chr == 'y' ]]; then
          confirm_required="" # already confirmed, no longer required
          break
        else
          sleep 1
        fi
      else
        sleep 1
      fi
    done
    echo "" # line feed
    # die if we were waiting for confirmation and the user never did.
    if [[ $confirm_required ]]; then
      echo "Exiting after the operation was not confirmed."
      exit 1
    fi
  fi
}

read -d "" -r SCARY_WARNING <<- END
	OMG THERE'S A MONSTER AT THE END OF THIS BOOK
	YOU REALLY DON'T WANT TO TURN THAT PAGE
	OH NOOOOOOOOO YOU DON'T KNOW WHAT YOU'RE DOING TO MEEEEEE
END

read -d "" -r INFORMATIONAL <<- END
	Some stuff is about to happen.
	We have some reasons to believe you might not like that stuff,
	or that you might not have realized that stuff was going to happen.
END

user_timeout 5 "$INFORMATIONAL"

user_timeout 10 "$SCARY_WARNING" 1

cat <<- END
	OH WOW THE MONSTER AT THE END OF THE BOOK IS ME
	IT IS FUZZY LOVABLE GROVER
	OH I AM SO HAPPY AND RELIEVED
END

