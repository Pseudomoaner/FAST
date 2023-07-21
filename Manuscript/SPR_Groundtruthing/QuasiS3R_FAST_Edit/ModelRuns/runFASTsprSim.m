function simResults = runFASTsprSim(inSets)
%% Global parameter definitions

%Settings applied to entire field
fieldSettings.fieldWidth = 100; %Width of the simulated domain (in units of fieldSettings.lam)
fieldSettings.fieldHeight = 100; %Height of the simulated domain (in units of fieldSettings.lam)
fieldSettings.maxX = fieldSettings.fieldWidth;
fieldSettings.maxY = fieldSettings.fieldHeight;
fieldSettings.fieldDepth = 10; %Depth of the simulated domain. Value is not critical, provided it is somewhat greater than the length of the longest rod in the simulation
fieldSettings.U0 = 250; %Potential amplitude. Value is not critical, provided it is sufficient to prevent rod-rod crossing (U0 = 250 does this)
fieldSettings.lam = 1.0; %Screening length, defining the interaction distance between rods
fieldSettings.f0 = 1; %Stokesian friction coefficient
fieldSettings.colJigRate = 0.0; %How quickly colours should 'jiggle' noisily (in HSV space). Values above 0 can be useful for visualising lineages of dividing cells. 
fieldSettings.postDivMovement = 'reverse'; %How the daughter cell should move following cell division. Either 'reverse' (the opposite direction to the mother) or 'same' (the same direction as the mother).
fieldSettings.growthRate = 0.0; %Average increase in aspect ratio over one unit of time.
fieldSettings.divThresh = 8; %Aspect ratio at which the cell should divide.
fieldSettings.zElasticity = inf; %Elasticity of the overlying substrate. Set to inf if you want to maintain cells in the monolayer.
fieldSettings.boundaryConditions = 'periodic';
fieldSettings.DT = inSets.DT; %Translational diffusion constant
fieldSettings.DR = inSets.DR; %Rotational diffusion constant
fieldSettings.DF = inSets.DF; %Fluorescence diffusion constant

%Choose your cell and barrier settings
barrierSettingsType = 'none'; %Type of static barriers that should be present in simulation - either none or loaded
barrierSettings = struct(); %Need to create a dummy variable to pass into the initialization function, even if you don't have any barriers in your system

%Settings for the active rods - note that the use of the 'LatticedXYCells'
%option means that all rods are assumed to be identical. Initialization can
%be customized by writing additional code in the WensinkField.populateField
%function.
cellSettingsType = 'FASTdists'; %Type of rod initialization conditions that should be applied - either singleCell, doubleCell, LatticedXYCells or FASTdists
cellSettings.ARa = 15.3; %Param. 1 of the aspect ratio Gamma distribution (acquired from data fitting)
cellSettings.ARb = 0.25; %Param. 2
cellSettings.FluoMu = 63.1; %Mean fluorescence intensity
cellSettings.FluoStd = 8.82; %Standard deviation of fluorescence intensity
cellSettings.noX = inSets.noX; %Number of rods distributed along the x-axis
cellSettings.noY = inSets.noY; %Number of rods distributed along the y-axis
cellSettings.f = inSets.F0; %Pushing force applied by each rod
cellSettings.r = 0; %Reversal rate associated with each rod

%Output settings
dispSettings.saveFrames = true; %Whether or not to save visualisations of each sampled timepoint
dispSettings.ImgPath = 'Frame_%04d.tif'; %Generic name for each output frame (will be fed into sprintf, so use appropriate string formatting)
dispSettings.colourCells = 'None'; %How rods should be recoloured at each sampling point. If set to 'None', will retain any previously set colour.
dispSettings.saveType = 'draw'; %Type of method used to visualise rods - either 'plot' or 'draw'. 'plot' will produce and save a Matlab figure, while 'draw' will draw ellipses directly into an image.
dispSettings.posVec = [100,100,round(900/sqrt(2)),900]; %Determines the location of the plotting figure - only needs to be set if dispSettings.saveType == 'plot'.
dispSettings.imagedirectory = [inSets.RootSim,filesep,'ColourCells']; %Defines where the output images will be located
if ~exist(dispSettings.imagedirectory,'dir') %Set up visualisation directory
    mkdir(dispSettings.imagedirectory);
end

%Processing settings
procSettings.startTime = 1; %Can be useful to cut out some times, if it takes some time for the model to settle down
procSettings.velocitySmoothingSize = []; %Size of the smoothing window used to smooth rod position data
procSettings.minTrackLength = 1; %Minimum length of a track to be kept following track assembly
procSettings.pixSize = 0.2; %In the same units as lam. Value is defined by the settings in WensinkField.drawField() (could bring those parameters out to here in the future)

%Global simulation settings (defined separately from e.g. field settings so
%they can easily applied uniformly during parameter sweeps).
fieldSettings.motiledt = 0.05; %Size of the timestep (to begin with)
samplingRate = inSets.dt; %How frequently samples of the simulation should be taken
settlingSimTime = 50; %How long it will take for the simulation to settle into an active configuration
targetSimTime = 200; %Target motile simulation time
fieldSettings.FrameSkip = round(samplingRate/fieldSettings.motiledt);

%% Part 0: Initialize field for this simulation
startField = WensinkField(fieldSettings.fieldWidth,fieldSettings.fieldHeight,fieldSettings.fieldDepth,fieldSettings.U0,fieldSettings.lam,fieldSettings.DR,fieldSettings.DT,fieldSettings.DF,fieldSettings.boundaryConditions);
startField = startField.populateField(barrierSettingsType,barrierSettings,cellSettingsType,cellSettings);

%% Part 1: Do initial simulation to allow system to reach an active configuration
fieldSettings.motileSteps = ceil(settlingSimTime/(fieldSettings.motiledt*fieldSettings.FrameSkip))*fieldSettings.FrameSkip;
[~,intermediateField] = simulateWensinkFieldInitial(startField,fieldSettings,dispSettings);

%% Part 2: Do another (fully sampled) simulation for a longer period of time - only data from this simulation period will be stored
fieldSettings.motileSteps = ceil(targetSimTime/(fieldSettings.motiledt*fieldSettings.FrameSkip))*fieldSettings.FrameSkip;
[PCs,endField] = simulateWensinkField(intermediateField,fieldSettings,dispSettings);

%% Part 3: Process data and save simulation results
fieldSettings.dt = fieldSettings.motiledt * fieldSettings.FrameSkip;
fieldSettings.maxF = round(fieldSettings.motileSteps/fieldSettings.FrameSkip);

[data,trackableData,toMappings,fromMappings,Tracks] = processModelPCs(PCs,procSettings,fieldSettings);

simResults.data = data;
simResults.trackableData = trackableData;
simResults.toMappings = toMappings;
simResults.fromMappings = fromMappings;
simResults.areaFrac = endField.getAreaFraction();
simResults.tracks = Tracks;