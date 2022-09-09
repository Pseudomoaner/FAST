#include <mex.h>
#include <math.h>
#include <matrix.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //xBets,yBets,lBets,nBets,thetBets,xAlph,yAlph,lAlph,nAlph,thetAlph,U0,lam,boundX,boundY,Width,Height are the input variables
    double *xBets, *yBets, *zBets, *lBets, *thetBets, *phiBets, *betInds, *nBets, *dUdx, *dUdy, *dUdz, *dUdthet, *dUdphi;
    double xAlph, yAlph, zAlph, lAlph, thetAlph, phiAlph, U0, lam, boundX, boundY, boundZ, Width, Height, Depth;
    int  nAlph, noBets;
    
    //Things declared for the energy calculation itself
    int betInd, bet, nBet, alphSeg, betSeg;
    double xBet, yBet, zBet, lBet, thetBet, phiBet, preFac, postFac, drdx, drdy, drdz, drdthet, drdphi, x, y, z, r, rInv, xiAlph, xjBet, yiAlph, yjBet, ziAlph, zjBet, alphPos, betPos, absX, absY, absZ, sgnX, sgnY, sgnZ; 
    
    if (nrhs != 20) {
        mexErrMsgTxt("Need 20 (!) input arguments!");
    }
    
    //Unload the input variables
    xBets = mxGetPr(prhs[0]);
    yBets = mxGetPr(prhs[1]);
    zBets = mxGetPr(prhs[2]);
    lBets = mxGetPr(prhs[3]);
    nBets = mxGetPr(prhs[4]);
    thetBets = mxGetPr(prhs[5]);
    phiBets = mxGetPr(prhs[6]);
    xAlph = mxGetScalar(prhs[7]);
    yAlph = mxGetScalar(prhs[8]);
    zAlph = mxGetScalar(prhs[9]);
    lAlph = mxGetScalar(prhs[10]);
    nAlph = (int)mxGetScalar(prhs[11]);
    thetAlph = mxGetScalar(prhs[12]);
    phiAlph = mxGetScalar(prhs[13]);
    U0 = mxGetScalar(prhs[14]);
    lam = mxGetScalar(prhs[15]);
    boundX = mxGetScalar(prhs[16]);
    boundY = mxGetScalar(prhs[17]);
    Width = mxGetScalar(prhs[18]);
    Height = mxGetScalar(prhs[19]);
    
    noBets = mxGetM(prhs[1]);
    
    //Create output matrices:
    plhs[0] = mxCreateDoubleMatrix(1,noBets,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,noBets,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1,noBets,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(1,noBets,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(1,noBets,mxREAL);
    dUdx = mxGetPr(plhs[0]);
    dUdy = mxGetPr(plhs[1]);
    dUdz = mxGetPr(plhs[2]);
    dUdthet = mxGetPr(plhs[3]);
    dUdphi = mxGetPr(plhs[4]);
    
    //Use the main energy determination function
    for (bet = 0; bet < noBets; bet++) { //For each other cell beta
        
        xBet = xBets[bet];
        yBet = yBets[bet];
        zBet = zBets[bet];
        lBet = lBets[bet];
        nBet = nBets[bet];
        thetBet = thetBets[bet];
        phiBet = phiBets[bet];
        
        preFac = U0/(nAlph * nBet);
        
        //Pairwise comparison of segments
        for (alphSeg = 0; alphSeg < nAlph; alphSeg++) {
            alphPos = (double)(alphSeg) - ((double)(nAlph-1)/2);
            for (betSeg = 0; betSeg < nBet; betSeg++) {
                betPos = (double)(betSeg) - ((double)(nBet-1)/2);
                
                xiAlph = xAlph + (lAlph * alphPos * cos(thetAlph) * cos(phiAlph));
                xjBet = xBet + (lBet * betPos * cos(thetBet) * cos(phiBet));
                yiAlph = yAlph + (lAlph * alphPos * sin(thetAlph) * cos(phiAlph));
                yjBet = yBet + (lBet * betPos * sin(thetBet) * cos(phiBet));
                ziAlph = zAlph + (lAlph * alphPos * sin(phiAlph));
                zjBet = zBet + (lBet * betPos * sin(phiBet));
                
                x = xiAlph - xjBet;
                y = yiAlph - yjBet;
                z = ziAlph - zjBet;
                                
                //Distance between two segmenets
                r = sqrt(x * x + y * y + z * z);
                rInv = 1/r;
                
                drdx = rInv * x;
                drdy = rInv * y;
                drdz = rInv * z;
                
                drdthet = rInv * lAlph * cos(phiAlph) * alphPos * (cos(thetAlph) * y - sin(thetAlph) * x);
                drdphi = rInv * lAlph * alphPos * (cos(phiAlph) * z - cos(thetAlph) * sin(phiAlph) * x - sin(thetAlph) * sin(phiAlph) * y);
                
                postFac = (exp(-r / lam) * (lam + r)) / (lam * r * r);
                
                dUdx[bet] = dUdx[bet] + (preFac * drdx * postFac);
                dUdy[bet] = dUdy[bet] + (preFac * drdy * postFac);
                dUdz[bet] = dUdz[bet] + (preFac * drdz * postFac);
                
                dUdthet[bet] = dUdthet[bet] + (preFac * drdthet * postFac);
                dUdphi[bet] = dUdphi[bet] + (preFac * drdphi * postFac);
            }
        }
    }

    return;
}