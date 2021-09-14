Jason R. Blevins, "Sequential Monte Carlo Methods for Estimating
Dynamic Microeconomic Models", Journal of Applied Econometrics,
Vol. 31, No. 5, 2016, pp. 773-804.

The data used in this paper were originally collected by John Rust and
were used for the application in the paper:

  John Rust, "Optimal Replacement of GMC Bus Engines: An Empirical Model
  of Harold Zurcher", Econometrica 55 (1987), 999-1033.

The data are publicly available as part of the NFXP software
distribution available at <https://editorialexpress.com/jrust/nfxp.html>.
The individual data files are in ASCII format and are vectorized into
a single column with a fixed number of lines containing metadata at
the top of each file. The format of the data files is detailed in the
NFXP software manual:

  John Rust, "Nested Fixed Point Algorithm Documentation Manual",
  Version 6, October 2000. Retrieved from
  <https://editorialexpress.com/jrust/nfxp.pdf> on March 25, 2015.

The following excerpt from John Rust's original README file for
the bus data describes the nature and format of the data files:

    This directory contains data on odometer readings and dates of
    bus engine replacements of 162 buses in the fleet of the Madison
    Metropolitan Bus Company that were in operation sometime during
    the period December, 1974 to May, 1985. The documentation of
    the contents of the files is described in more detail in chapter
    4 of the documentation manual.
    
    The directory contains the following files, each
    corresponding to a different model/vintage of bus
    in the Madison Metro fleet:
    
    D309.ASC     110x4 matrix for Davidson model 309 buses
    G870.ASC     36x15 matrix for Grumman model 870 buses
    RT50.ASC     60x4  matrix for Chance model RT50 buses
    T8H203.ASC   81x48 matrix for GMC model T8H203 buses
    A452372.ASC 137x18 matrix for GMC model A4523 buses, model year 1972
    A452374.ASC 137x10 matrix for GMC model A4523 buses, model year 1974
    A530872.ASC 137x18 matrix for GMC model A5308 buses, model year 1972
    A530874.ASC 137x12 matrix for GMC model A5308 buses, model year 1974
    A530875.ASC 128x37 matrix for GMC model A5308 buses, model year 1975
    
    The data in each file are vectorized into a single column: e.g.
    D309.ASC is a 440x1 vector consisting of the columns
    of a 110x4 matrix stacked on top of each other consecutively.

For the complete NFXP software distribution, including the data files,
documentation, and a collection of Gauss programs for processing the
data and estimating a dynamic discrete choice model using the NFXP
algorithm, see the following website:
<https://editorialexpress.com/jrust/nfxp.html>.

The file rust-data.zip contains the files

  a452372.asc  a530872.asc  a530875.asc  g870.asc  t8h203.asc
  a452374.asc  a530874.asc  d309.asc     rt50.asc

which are the ones described above, except that the names are lower
case. These files are ASCII files in DOS format. Unix/Linux users
should use "unzip -a".

Jason Blevins
blevins.141 [AT] osu.edu