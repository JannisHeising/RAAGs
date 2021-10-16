Graph Adjustment:

The underlying Artin graph is determined by the file set in 'settings.json'.
'#generators' is the number of vertices, i.e. generators, and edges can be added or removed by adhering to the
presented format which should hopefully be obvious (don't forget to add any necessary commas).


Controls:

'r' key: Reset the graph
'a' key: toggle auto-rotation
's' key: toggle arrow
'd' key: switch between ball and sphere
scroll wheel: zoom in/out
ctrl + scroll wheel: increase/decrease radius of the ball
click & drag: manually rotate the graph
1-9 keys: "shadow" certain generators, i.e. make their edges attract less
'F1': toggle the interface on/off
'p': save the graph to "edges.txt"


Sliders:

1: Adjust the step size (if the graph "explodes", turn this very low and press 'r')
2: Adjust the exponent of the force pulling adjacent nodes together (left = 0, right = 4)
3: Adjust the exponent of the force pushing non-adjacent nodes apart (left = 0, right = -4)
4: Adjust how far the pushing force reaches (exponential, arbitrary unit, left = 0.007, right = 148)
5: Adjust the impact of the "shadow" effect (the value by which the attraction force is multiplied, left = 0, right = 0.05)


Settings:

The 'settings.json' file determines the following settings:
'filename': The file to be loaded
'max_radius': The radius (from the neutral element) up to which the Cayley graph is to be generated
'lag_relief': The probability that an unrendered vertex doesn't get computed. If this is neither 0 nor 1, vertices will
	jump around when using 'ctrl + sroll wheel'.


Notes:

-Usually the first slider initially has to be low but can be set higher as randomness decreases.
-Turning the fourth slider down may significantly reduce computation time.


Troubleshooting:

-If the graph is unintentionally just a line (Z), this means that the program couldn't find or decipher the graph file.
-If the graph is unintentionally completely free, i.e. doesn't contain extra edges, this means that the edges in the graph file
	aren't formatted correctly. One reason could be that the number of generators isn't large enough for the specified edges.