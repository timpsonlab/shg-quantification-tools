#include <mex.h>
#include <math.h>
#include <cstdlib>
#include <vector>
#include <exception>

const int n = 256;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Compute GLCM matrix
    // [correlation, contrast, energy, homogeneity] = glcm(im, offset_x, offset_y, reject_zero)
    // if reject_zero is true, do not count zero pixels (allows thresholding)
    
    // Check inputs
    if (nlhs == 0)
        return;
    
    if (nrhs < 3)
        mexErrMsgTxt("Should be at least three inputs");
    
    if (!mxIsUint8(prhs[0]))
        mexErrMsgTxt("Intput should be a UINT8 matrix");
    
    if (mxGetNumberOfDimensions(prhs[0]) != 2)
        mexErrMsgTxt("Intput should be a 2D matrix");

    bool reject_zero = false;
    if (nrhs >= 4)
        reject_zero = (bool) mxGetScalar(prhs[3]);
    
    try
    {
        std::vector<double> glcm(n*n);

        int w = mxGetN(prhs[0]);
        int h = mxGetM(prhs[0]);
        unsigned char* im = (unsigned char*) mxGetData(prhs[0]);

        int offset_x = mxGetScalar(prhs[2]);
        int offset_y = mxGetScalar(prhs[1]);
        int n_px = 0;   

        // Compute GLCM
        for (int y=0; y<h; y++) 
        {
            for(int x=0; x<w; x++)
            {
                int xo = x + offset_x;
                int yo = y + offset_y;

                if ((xo >= 0) && (yo >= 0) && (xo < w) && (yo < h))
                {
                    unsigned char a = im[x + y * w];
                    unsigned char b = im[xo + yo * w];

                    if (!reject_zero || (a & b))
                    {                        
                        glcm[a + b * n]++;
                        n_px++;
                    }
                }
            }
        }

        double correlation = 0.0;
        double contrast = 0.0;
        double energy = 0.0;
        double homogeneity = 0.0;
        double pa = 0;
        double pb = 0;
        double stdeva = 0.0;
        double stdevb = 0.0;

        // Compute means
        for (int b=0; b<n; b++) 
            for (int a=0; a<n; a++) 
            {
                pa += a * glcm[a+b*n];
                pb += b * glcm[a+b*n];
            }

        pa /= n_px;
        pb /= n_px;

        // Compute standard deviations
        for (int b=0; b<n; b++) 
            for (int a=0; a<n; a++) 
            {
                stdeva += (a - pa) * (a - pa) * glcm[a+b*n];
                stdevb += (b - pb) * (b - pb) * glcm[a+b*n];
            }

        stdeva = sqrt(stdeva/n_px);
        stdevb = sqrt(stdevb/n_px);

        // Compute correlation parameter
        for (int b=0; b<n; b++) 
            for (int a=0; a<n; a++) 
            {
                double g = glcm[a+b*n];
                correlation += (a - pa) * (b - pb) * g;
                contrast += (a-b)*(a-b) * g;
                energy += g * g;
                homogeneity += g / (1 + std::abs(a-b));
            }

        correlation /= (stdeva * stdevb * n_px);

        if (nlhs >= 0)
            plhs[0] = mxCreateDoubleScalar(correlation);
        if (nlhs >= 1)
            plhs[1] = mxCreateDoubleScalar(contrast);
        if (nlhs >= 2)
            plhs[2] = mxCreateDoubleScalar(energy);
        if (nlhs >= 3)
            plhs[3] = mxCreateDoubleScalar(homogeneity);
    }
    catch(std::exception e)
    {
        mexErrMsgTxt(e.what());
    }
}