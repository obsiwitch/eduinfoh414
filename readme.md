# INFO-H-414 - Swarm Robotics Project (2015)

## Build instructions

~~~
> mkdir build
> cd build
> cmake -DCMAKE_BUILD_TYPE=Release ../src/decision_making
> make
> cd ..
> source env.sh
> argos3 -c decision-making.xml
~~~

## Run 10 experiments sequentially

~~~
> run.sh
~~~

The ```run.sh``` will launch argos3 with the experiment configuration file and
the preloaded script on robots. Launch the experiment in the simulation window
and stop it approximately when you think it is finished. A file containing
information on the current experiment configuration and a file with the results
of the exeperiment are generated in the ```out/``` directory. The next
experiment is launched when the current experiment's simulation window is closed.
