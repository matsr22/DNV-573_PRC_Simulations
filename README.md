# DNV-matlab-code
 
As of 25/01/25 the simulation currently does the following:

1)

Reads combined wind and rain data, in the form of a frequency distribution matrix in a .mat file format

2)

Reads V-N data from the specific material under scruitiny and considers this data with a statistical approach

3)

Loads in measured material properties such as impedance values and sets any universal constants / assumptions

4)

Wind speeds are converted to blade tip speeds by a conversion table and interpolation. 

5)

Assuming that erosion is driven by fatigue, a modified springer method as described by DNV-573 is implemented to compute the allowed impingements before damage starts to appear at each of the domain tip speeds and droplet diameter.

6) 

Using 


25/01/25 Improvements to be made / Current issues

1) The V-N data is currently being read from a spreadsheet with no data on the droplet diameter of the test, this has to be inputed seperatley. Ideally the spreadsheet should be a .mat file so the RET diameter can be loaded in at the same time. 


