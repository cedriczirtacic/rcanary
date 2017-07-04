# rcanary
Reads canar(y|ies) value and address for binaries running at the moment. Makes use of Auxiliary Vectors information in /proc/{PID}/auxv, reads the address where the canary is located in memory and then looks through /proc/{PID}/mem for it's value.

This is ported from elttam's [script](https://github.com/elttam/canary-fun) and based on their [research](https://www.elttam.com.au/blog/playing-with-canaries).

# XXX
The script should work on 32bit based systems but didn't have the time to test it.
