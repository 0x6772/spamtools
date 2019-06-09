#!/bin/sh

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

# I run this for each of my users (whose MUAs are configured to move
# "deleted" messages to ~/deleted-ham and to move junk/spam messages
# to ~/missed-spam) nightly (in each user's crontab).

# Anything in ${MISSED_SPAM} and ${DELETED_HAM} will get a
# cat /dev/null >| after being processed. ${ADDITIONAL_~} won't.
#
# ~ expansion works, even if you have a real sh(1) (eg, you're not
# Linux), provided your eval dtrt.
#
# It's okay if the ADDiTIONAL lists are empty.
#
# The From/To headers from $MISSED_SPAM are echoed because some
# times I see obvious patterns in them and write my own SpamAssassin
# rules based on that. If that's useless to you, just comment that
# line out.

MISSED_SPAM="~/Mail/missed-spam"
ADDITIONAL_SPAM=""

DELETED_HAM="~/Mail/deleted-ham"
# XXX deal with mailboxes with spaces in their name in a sane way
# (right now we just straight break)
ADDITIONAL_HAM="~/Mail/Archives ~/Mail/Sent"
# not walking all of ~/Mail, but try this for a bit, see if it
# improves positive ratings and makes Thunderbird shut up a bit
# - 2019-03-13

(
echo SPAM
for i in ${MISSED_SPAM}
do
  file_path=`eval echo $i`
  if [ -f $file_path ]
  then
    echo "->${file_path}"
    egrep '(^ *From|^ *Subject)' `eval echo ${file_path}`
    sa-learn --spam --mbox --progress ${file_path} \
      && cat /dev/null >| ${file_path}
  else
    echo "  ${file_path} does not appear to be an mbox file."
  fi
done

for i in ${ADDITIONAL_SPAM}
do
  file_path=`eval echo $i`
  if [ -f $file_path ]
  then
    echo "->${file_path}"
    sa-learn --spam --mbox --progress ${file_path}
  else
    echo "  ${file_path} does not appear to be an mbox file."
  fi
done
)

echo

(
echo HAM
for i in ${DELETED_HAM}
do
  file_path=`eval echo $i`
  if [ -f $file_path ]
  then
    echo "->${file_path}"
    sa-learn --ham --mbox --progress ${file_path} \
      && cat /dev/null >| ${file_path}
  else
    echo "  ${file_path} does not appear to be an mbox file."
  fi
done
for i in ${ADDITIONAL_HAM}
do
  file_path=`eval echo $i`
  if [ -f $file_path ]
  then
    echo "->${file_path}"
    sa-learn --ham --mbox --progress ${file_path}
  else
    echo "  ${file_path} does not appear to be an mbox file."
  fi
done
)
