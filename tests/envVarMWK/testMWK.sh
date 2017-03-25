#! /usr/bin/env bash

# Tests to verify $MWK is properly set,
# and Miki works correctly with it.
# https://github.com/a3n/miki

cat <<EOF >/dev/null
How to test:

1. No need to reinstall prerequisites if nothing's changed.

2. Recommended to create a new wiki directory just for test,
   then set MWK to that directory:

   $ mkdir ~/your/new/wiki/test/directory
   $ export MWK=~/your/new/wiki/test/directory

3. Copy the convenience scripts from this repo to your path.
   Back up the existing ones if you want to go back to them.

   From the repo directory that you're testing:

   $ cp mwk newmeta ~/bin/. # Or wherever you keep your shell scripts.
   $ cd ~/bin
   $ chmod ug+x mwk newmeta # Make them executable.

4. From the repo directory that you're testing:

   $ cp -r ExampleTopic makefile mdStarter.md rstStarter.rst $MWK/.

   Ensure that makefile is the version being tested.

5. In the repo directory that you're testing,
   cd to this directory and run this script.
   Something like one of these:

   $ cd <repoClone>/tests/envVarMWK
   $ chmod ug+x ./runtest.sh
   $ ./runtest.sh

   The script should run to completion,
   and exit with $? = 0.

   If failure, the script will stop at the point of failure,
   print an error message,
   and exit with $? != 0.
EOF

set -o errexit

goodTest=0
badArgs=2
badTest=9
backupMWK=$MWK

testFailed () {
    if [ $# -ne 2 ]
    then
        printf "testFailed() must be called with exactly 2 arguments.\n"
        printf "$*\n"
        exit $badArgs
    fi

    printf "$1\n" # Failure reason message.
    printf "test FAIL\n"
    exit $2 # Failure exit code.
}

printf "\nTest mwk happy paths.\n\n"

if ! (set -x; which mwk)
then
    testFailed "mwk not on path." $badTest
fi
printf "OK\n\n"


if (set -x; ! [ -d "$MWK" ] )
then
    testFailed "\$MWK not set or not a directory." $badTest
fi
printf "OK\n\n"


if (set -x; ! [ -f "$MWK/makefile" ] )
then
    testFailed "Can't find $MWK/makefile." $badTest
fi
printf "OK\n\n"


if ! (echo "\$MWK: $MWK"; set -x; mwk clean)
then
    testFailed "mwk clean fails for no tested reason." $badTest
fi
printf "OK\n\n"


printf "Test that mwk protects makefile from bad \$MWK\n\n"


if (set -x; unset MWK; mwk clean)
then
    testFailed "mwk does not detect unset MWK." $badTest
fi
printf "OK\n\n"


if (set -x; export MWK= ; mwk clean)
then
    testFailed "mwk does not detect MWK set to empty string." $badTest
fi
printf "OK\n\n"


if (set -x; export MWK=$MWK/makefile ; mwk clean)
then
    testFailed "mwk does not detect MWK set to file." $badTest
fi
printf "OK\n\n"


printf "Test makefile directly, without mwk.\n\n"


printf "Test makefile happy path.\n\n"


mkf=$MWK/makefile


if ! (set -x; make -f $mkf clean)
then
    testFailed "make -f $mkf clean fails for no tested reason." $badTest
fi
printf "OK\n\n"


printf "Test makefile response to bad \$MWK.\n\n"


if (set -x; unset MWK; make -f $mkf clean)
then
    testFailed "make -f $mkf clean fails to detect unset \$MWK." $badTest
fi
printf "OK\n\n"


if (set -x; export MWK= ; make -f $mkf clean)
then
    testFailed "make -f $mkf clean fails to detect empty \$MWK." $badTest
fi
printf "OK\n\n"


if (set -x; export MWK=$MWK/makefile ; make -f $mkf clean)
then
    testFailed "make -f $mkf clean fails to detect incorrectly set \$MWK." $badTest
fi
printf "OK\n\n"


printf "Test newmeta happy path.\n\n"


if ( [ -f meta.json ] )
then
    echo "#########"
    echo "# meta.json exists in the current directory."
    echo "# Verify that this file is not needed, delete it,"
    echo "# and start the test over."
    echo "#########"
    exit 1
fi


if ! (set -x; which newmeta)
then
    testFailed "newmeta not on path." $badTest
fi
printf "OK\n\n"


printf "Test newmeta \$MWK detection.\n\n"


if (set -x; unset MWK ; newmeta .)
then
    testFailed "newmeta failed to detect unset MWK." $badTest
fi
rm -f meta.json
printf "OK\n\n"


if (set -x; export MWK= ; newmeta .)
then
    testFailed "newmeta failed to detect empty MWK." $badTest
fi
rm -f meta.json
printf "OK\n\n"


if (set -x; export MWK=$MWK/makefile ; newmeta .)
then
    testFailed "newmeta failed to detect incorrect MWK." $badTest
fi
rm -f meta.json
printf "OK\n\n"

printf "All tests PASS\n"
