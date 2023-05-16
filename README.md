# gamesavebkp
to do: add a step by step image guide on how to set up the bat

Quick and dirty temp tutorial

1) Edit 4 variables: PATH, BACKUPPATH, PREFIX, DYNAMICFILE
- Note: BACKUPPATH is a sub directory based on path
- do not start variables with a "\"

2) create a windows task in the task scheduler to run the bat file every hour. Here is how I have mine setup. The "Action" just points to the bat file.

![1](https://i.imgur.com/WetyRlR.png)
![2](https://i.imgur.com/PQTbnjy.png)
![3](https://i.imgur.com/F1QVJDu.png)

Note: Under General, "Run with highest privileges" must be checked for "hidden" to work; so the task runs silently in the background.

I personally name the  bat file based on the game I'm using it for, like "wolongsavebkp.bat" -- and having the bat file located in the game's install directory. 
