#include <math.h>
#include <string.h>
#include "mex.h"

double abso(double a){
    if (a<0){
        return -a;
    }
    return a;
}

double maxi(double a,double b){
    if (a<b){
        return b;
    }
    return a;
}

double mini(double a,double b){
    if (a>b){
        return b;
    }
    return a;
}

//bfilter2Gray(A,B,rows,cols,w,sigma_r,G)

void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ])
{
	double rows,cols,w,sigmar;
    double * A;/*Input image*/
    double * B;/*Output image*/
    double * G;
	
	int i,j,ii,jj;

    
    /*Input Memory allocation*/
    A=mxGetPr(prhs[0]);
    B=mxGetPr(prhs[1]);
	rows = mxGetScalar(prhs[2]); 
	cols = mxGetScalar(prhs[3]); 
	w = mxGetScalar(prhs[4]); 
	sigmar = mxGetScalar(prhs[5]); 
    G=mxGetPr(prhs[6]);
    
    for (i=0;i<rows;i++){
        for (j=0;j<cols;j++){
			double Aij;
			double num, denom, t;
			
            Aij=A[(int)(j*rows+i)];
			
            iMin = maxi((double)i-w,(double)0.0);
            iMax = mini((double)i+w,(double)rows);
            jMin = maxi((double)j-w,(double)0.0);
            jMax = mini((double)j+w,(double)cols);
            
            num=0;
            denom=0;
            t=0;
            for (ii=iMin;ii<iMax;ii++)
			{
                for (jj=jMin;jj<jMax;jj++)
				{
                    if(ii<>i || jj<>j)
					{
						double Aiijj,v,vv;
                        Aiijj=A[(int)(jj*rows+ii)];
                        
                        v=(i-ii)*(i-ii)+(j-jj)*(j-jj);
                        vv=abso( xij - xiijj );
                        vv=vv*vv;
                        t= exp(-0.5*v/(sigma_d*sigma_d));
                        t=t*exp(-0.5*(vv)/(sigma_r*sigma_r));
                        num=num+xiijj*t;
                        denom=denom+t;
                    }
                }
            }
            
            if (!(denom==0)){
                y[(int)(k)]=num/denom;
            }
            else{
                y[(int)(k)]=x[(int)(k)];
            }
            k=k+1;
        }
    }
    
}


/*
% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
%h = waitbar(0,'Applying bilateral filter...');
%set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
dim = size(A);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = A(iMin:iMax,jMin:jMax);
      
         % Compute Gaussian intensity weights.
         H = exp(-(I-A(i,j)).^2/(2*sigma_r^2));
      
         % Calculate bilateral filter response.
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
   %waitbar(i/dim(1));
end
*/

