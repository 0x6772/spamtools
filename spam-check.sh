#!/bin/sh

MISSED_SPAM=~/Mail/missed-spam

echo `egrep -c '(^ *From )' ${MISSED_SPAM}` messages
echo
egrep '(^ *From|^ *Subject)' ${MISSED_SPAM}
