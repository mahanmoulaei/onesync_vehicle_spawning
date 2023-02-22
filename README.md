# This is a snippet for server-side vehicle spawning in FiveM OneSync

* It is more optimized than most methods out there [so far] (however I could do some tweaks to optimize it more than its current state, and that'll be done eventually)
* Applies vehicle properties in a better & more optimized way(it doesn't use state bags & state bags change handlers, so not all clients will be invoked)
* Both client-side and server-side exports, spawn the vehicles server-sided
* Important events are sensitive to exploit and are secured
