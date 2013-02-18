#include "BandedMatrix.h"

__device__ void bmAx( float* b, const BandedMatrix a, float const* x )
{
   int nthreads = blockDim.x*gridDim.x;
   int i = blockIdx.x*blockDim.x + threadIdx.x;
   int j;
   float bi = 0.f;
   
   while( true )
   {
      if( i < a.rows )
      {
         // NOTE: sometimes i+a->bands[j] is a bad index into x[], but we
         // guarantee that when it is a bad index, a[j+i*a->nbands] == 0.f,
         // so as long as there is no segfault, we don't have to branch here.
         for( j = 0; j < a.nbands; ++j )
            bi += a.a[j+i*a.nbands] * x[i+a.bands[j]];
         
         b[i] = bi;
      }
      
      if( __any(i >= a.rows) )
         break;
      
      i += nthreads;
   }
}

__global__ void bmAx_k( float* b, const BandedMatrix a, float const* x )
{
   bmAx(b,a,x);
}
