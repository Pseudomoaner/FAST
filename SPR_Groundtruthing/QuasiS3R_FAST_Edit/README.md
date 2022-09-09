# QuasiS3R
Quasi-3D SPR (Self Propelled Rod) model, designed for simulation of bacterial motility in dense collectives confined to a single layer. Also allows simulation of 2D confinement, cell growth and division and periodic reversals in cell motility.

## Building up a simulation script

The QuasiS3R model has been built to permit a range of flexible simulation types. To set the simulation specifications, it is simply necessary to define a series of variables at the top of a script from which the simulation is run. The ModelRuns\Run2DModel.m script provides a template for this simulation script - full details of each parameter can be found within. 

## Visualising the results

QuasiS3R will automatically generate a visualisation of the system at each sampled timepoint, located in the directory specified by `dispSettings.imagedirectory`. You can visualise the results as a movie by following the steps laid out in the [FAST wiki](https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:overlays#converting_from_frames_to_a_movie).

To prevent saving frames, simply set `dispSettings.saveFrames = false`.

## Speeding up simulations by pre-compiling code

One of the most time-consuming portions of the QuasiS3R model is calculation of the potential gradients acting on each rod, which confer the rod-rod steric interactions. To speed up this process, the QuasiS3R package includes a pair of .c files that perform these expensive operations (PotentialCalculations\mexCalcEnergyGradientsPeriodic.c and  PotentialCalculations\mexCalcEnergyGradients.c) that can be pre-compiled. To use them, simply follow [this guide](http://cs.smith.edu/~nhowe/370/Assign/mexfiles.html) to compiling .mex files. 

Once you have compiled these functions, they should be saved as QuasiS3R\PotentialCalculations\mexCalcEnergyGradients.mexXXX and QuasiS3R\PotentialCalculations\mexCalcEnergyGradientsPeriodic.mexXXX (where XXX is an operating system specific extension). QuasiS3R will then automatically detect the compiled versions and use them in place of the equivalent .m functions.

## Applying custom confinement geometry

To help build up complex geometries of spatial confinement, QuasiS3R includes the fieldDesigner utility. To use it, simply open the FieldDesigner.mlapp in Matlab. Upon doing so, the following GUI should appear: 

![fieldDesigner](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesigner.PNG)

In the lower left corner, the fieldDesigner utility allows selection of the dimensions of the underlying simulation domain (selected with **Field height** and **Field width**), as well as the boundary conditions to be applied to the system (**Periodic**, **Unbounded** or **Box** - note that the 'Box' option applies confinement around the entire perimeter of the domain, in addition to any defined geometrical confinement).

To build up the geometry of the confinement of your system, click on the **Drawing** drop down menu and select one of the shapes. In the case of the **Polygon** selection, an additional dialog will appear to ask how many corners the polygon should have:

![polygon selection](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesignerHexagonSelect.PNG)

You will now see your selected shape appear in the top right-hand corner:

![polygon design](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesignerHexagonEdit.PNG)

This shape can now be manipulated in the geometry required, using the selectable nodes:

![V shape](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesignerHexagonEdit2.PNG)

You can now click the **Add** or **Subtract** buttons to add or subtract the specified shape from the current geometry. By default, the geometry field is empty, so in the initial step the 'Add' button should be selected. This will update the design window in the lower right:

![design window update](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesignerHexagonGeometry.PNG)

You can then repeatedly apply the drawing tools, adding and subtracting from the system geometry as needed, until your system has the desired geometry:

![complex design](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/fieldDesignerHexagonGeometry2.PNG)

Once you're happy with your system geometry, simply click File -> Save to save a configuration file with the specified system setup. You will now need to include the following code in your model initialization script:

``` matlab
load('Path\To\Configuration\File\fieldConfig.mat');
switch fieldConfig.BoundaryConds %Choose 'periodic' or 'none' (none also covers 'box' from the configuration file)
    case 'none'
        fieldSettings.boundaryConditions = 'none';
    case 'box'
        fieldSettings.boundaryConditions = 'none';
    case 'periodic'
        fieldSettings.boundaryConditions = 'periodic';
end

barrierSettingsType = 'loaded';
barrierSettings.CPs = fieldConfig.CPs;
barrierSettings.fieldImg = fieldConfig.FieldDesign;
barrierSettings.resUp = fieldConfig.resUp;
```

This will automatically apply the settings defined using the fieldDesigner GUI to your model.

![V-shaped obstacle](https://raw.githubusercontent.com/Pseudomoaner/QuasiS3R/master/Graphics/Vobstacle.PNG)

Please note that the functionality associated with the fieldDesigner utility is somewhat untested, and may break your model.

## Contributors

- Oliver J. Meacock
- William P. J. Smith

## References

- Wensink, H. H., & Löwen, H. (2012). Emergent states in dense systems of active rods: From swarming to turbulence. Journal of Physics Condensed Matter, 24(46). https://doi.org/10.1088/0953-8984/24/46/464130
- Lowen, H., Dunkel, J., Heidenreich, S., Goldstein, R. E., Yeomans, J. M., Wensink, H. H., & Drescher, K. (2012). Meso-scale turbulence in living fluids. Proceedings of the National Academy of Sciences, 109(36), 14308–14313. https://doi.org/10.1073/pnas.1202032109
- Meacock, O. J., Doostmohammadi, A., Foster, K., Yeomans, J. M., Durham, W. M. (2020). Bacteria solve the problem of crowding by moving slowly. arXiv:2008.07915
