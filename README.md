# The All-Seeing Eye
## Church of Hardcore
### A World of Warcraft Verification and Logging Addon

This addon provides data integration with the **Hardhead** website (coming soon).

#### In:
 - `/ase` and `/allseeingeye` base slash commands,
 - "All-Seeing Eye" config/options area, with sample widgets
 - Character Profile support via Ace3 (see Interface Options -> AddOns -> All-Seeing Eye -> Profiles) 
 - Mini-map Icon,
 - Tool-tip for enabled/disabled
 - Open Interace Options -> AddOns -> All-Seeing Eye with RMB on Mini-map Icon
 - Open Main GUI Window with LMB on Mini-map Icon (treat as RMB until GUI is ready)
 - Add colour support for simplifying UI
 - Add rough base GUI Window

#### Next:
 - DESTINATION: Armory
 - On-Demand String Exporter (gathers copies of everything, builds string)
 - Version string / slash command

#### Guild Inviter:
 - Pump the handle on the black box model
 - User opens the Guild Inviter dialog, and is greeted with one or more buttons
 - "Invite me to x" buttons - the user knows which guild they wish to join, and so no "choose the right guild" mechanics are required
 - "Invite me" button - general no-thought solution that assigns you to a guild

 - due to protected methods being involved, things must be triggered by a user action.
 - As such, we'll funnel all the user interface priming (button clicks, weird world-frame hacks) to a single 'ok what's next?' method
 - the method pumps a finite-state-machine onwards towards the end-goal, and logs its output appropriately

Example:
User presses the 'join named guild' button
Pump:
	BlackBox checks state, sees this is a new request. Inits, then issues the state/command for "join named guild, no results, search started"
	JoinNamedGuild procedure started
	Guild name identified
	Who command issued
	Update UI
Pump:
	Checks state, sees we're waiting for results from Who
	Check timeouts, time since last pump, etc
	Pump Who
	Update UI

CALLBACK:
	Callback loads all state info
	Records all results received, updates totals etc
	Updates state for 'some results received' and 'all done' appropriate

Pump:
	Detects a callback has fired
	Count number of results - if we have enough, cancel the Who
	Add names to the 'list of possible 
