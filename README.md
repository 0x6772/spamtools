# spamtools
Just some lightweight scripts I use to maintain SpamAssassin/Postfix/Dovecot

## gr-sa-learn.sh
I run this for each of my users (whose MUAs are configured to move
"deleted" messages to `~/deleted-ham` and to move junk/spam messages
to `~/missed-spam`) nightly just before 02:00 local (in each user's
crontab).

Anything in `${MISSED_SPAM}` and `${DELETED_HAM}` will get a
`cat /dev/null >|` after being processed. `${ADDITIONAL_~}` won't.

~ expansion works, even if you have a real `sh(1)` (eg, you're not
Linux), provided that shell's `eval` dtrt.

It's okay if the ADDiTIONAL lists are empty.

The From/To headers from `$MISSED_SPAM` are echoed because some
times I see obvious patterns in them and write my own SpamAssassin
rules based on that. If that's useless to you, just comment that
line out.

## spam-check.sh
Just the "From/To" headers part of gr-sa-learn.sh.

I run this nightly around 20:00 local. (So in case I want to
actually *look* at the offending message more than just its headers,
I've got a few hours to do that before gr-sa-leanr.sh nukes it from
orbit.

## watch_spam.sh
Pretty trivial, but I found myself typing this too damn often.

`tail(1)`s Postfix's (or whatever your MTA is) `maillog` and
`procmail(1)`'s user-specific log (you DO have `LOGFILE` set in
`~/.procmailrc`, right?) in the background (which, since it's within a
shell script, detaches from the calling shell entirely), captures
the pids of those two tail(1) processes, and emits them (so you can
clean up the procs).
