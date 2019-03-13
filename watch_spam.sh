#!/bin/bash

# tail(1)s Postfix's (or whatever your MTA is) maillog and
# procmail(1)'s user-specific log (you DO have LOGFILE set in
# ~/.procmailrc, right?) in the background (which, since it's within a
# shell script, detaches from the calling shell entirely), captures
# the pids of those two tail(1) processes, and emits them (so you can
# clean up the procs).

# Copyright (c) 2019 Alan Gabriel Rosenkoetter
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

MAILLOG=/var/log/maillog
PROCLOG=`awk -F= '$1 ~ /^LOGFILE$/ { print $2 }' ~/.procmailrc`

pids=''

# Lame! don't want to use -b, can't get the pid for cleanup if we do
# that. But if we do this and /etc/sudoers says "never cache
# passwords", this hack won't work. Boo!
sudo echo
wait $!
sudo sh -c 'tail -f /var/log/maillog' > >( grep spamd ) &
pids=`echo $!`
tail -f ~/procmail/log &
pids="${pids} `echo $!`"

sleep 1

printf "To clean up:\n  sudo kill ${pids}\n"
