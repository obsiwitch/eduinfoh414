# INFO-H-414 - Swarm Robotics Project

## Build instructions

~~~
> mkdir build
> cd build
> cmake -DCMAKE_BUILD_TYPE=Release ../src/decision_making
> make
> cd ..
> source variables
> argos3 -c decision-making.xml
~~~

## Run 30 experiments sequentially

~~~
> run.sh
~~~

The ```run.sh``` will launch argos3 with the experiment configuration file and
the preloaded script on robots. Launch the experiment in the simulation window
and stop it approximately when you think it is finished. A result file will
be generated in the ```out/``` directory. The next eperiment is launched when
the current experiment's simulation window is closed.
