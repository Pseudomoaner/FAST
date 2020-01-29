function normalizedVec = normalizeVector(inputVec)
%Based on the comment in figure 3 of Wensink et al (2015). Performs a normalization of 2D velocity distributions

normalizedVec = (inputVec - mean(inputVec))/std(inputVec);