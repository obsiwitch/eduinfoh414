# Speaker Notes

## Title

* Do a quick demo as an introduction.
* I obviously decided to show an experiment that works, but I’ll talk
later about problems.


## Main steps - Start

Here we have robots at the start of the experiment.

## Main steps - Split

Then, they split by going to the nearest door. Obviously, doing it this way
implies that there will be problems if robots are not well distributed in the
central room at the start of the experiment.

## Main steps - Evaluate

Once they have passed a first threshold, the door step, robots are drawn inside
the room by targets.
Ground robots are attracted by the door step, and Light robots are attracted by
the light source. Moreover, there are interactions between robots themselves to
try to avoid blocking room entrances.
In parallel, robots evaluate a component of the room’s score, the ground’s color
for ground robots, and the light intensity + the number of objects for Light
robots.
A robot consider it has finished partially evaluating its room when its score
has not improved for a specific number of time steps. Robots with a finished
partial evaluation have white leds.

## Main steps - Gather & Sync

Then, robots with partial scores are attracted by far robots with partial and
complete scores.
They gather approximately at the center of the room to exchange partial scores
and compute total scores.
Once they have their total score for their associated room, they can share it
and only keep the best received score.
Robots become blue when they have not received an improving total score for a
specific number of steps.
When they have finished choosing the best room, robots are attracted by the
best room’s door.

## Main steps - Best room

To stay inside the best room, robots are attracted by the nearest light source
and nearest object inside the room.

## Analysis

To analyse the quality of this implementation, I ran 110 experiments with
multiple combinations of parameters N, which is the swarm size, and rho, which
is the number of ground robots on the total number of robots.

As you can see with these number, in only 67 experiments robots were in the
best room at the end.
So, what are the problems with this implementation?

## Problems - diversification

The main problem is that robots go to the nearest room at the beginning. Some
rooms might not have a robot of each type, and in the worst case, some rooms
might not have robots assigned to it.

One solution would be to assign robots to rooms at the beginning of the program,
and try to diversify the population by using the range_and_bearing system. If n
robots have chosen the same room, then there is a 1/n chance that a robot will
keep this room, else it will choose randomly another room.

Another solution would to execute the main steps multiple times.

## Other problems

The score is an approximation, robots move and evaluate a room until the score
has not been improved for a specific number of steps. Executing multiple times
the main steps could be a way of having more chance to obtain correct scores.

As for the second problem, the more there are robots, the more it is difficult
to make them fit inside a room without them blocking each other.
