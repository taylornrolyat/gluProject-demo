//
//  miniGLU.m
//  miniGLU
//
//  Created by Taylor Triggs on 4/26/13.
//  Copyright 2013 Cal State Channel Islands. All rights reserved.
//
//  NOTE: This is a modified version of the function of the same name from
//        the Mesa3D project and is  licensed under the MIT license,
//        which allows use, modification, and redistribution

#import "miniGLU.h"

// gluProject maps 3D object coordinates to window coordinates
GLint gluProject(GLfloat objx, GLfloat objy, GLfloat objz,
				 const GLfloat modelMatrix[16],
				 const GLfloat projMatrix[16],
				 const GLint   viewport[4],
				 GLfloat *winx, GLfloat *winy, GLfloat *winz)
{
    float in[4];
    float out[4];
    
    in[0] = objx;
    in[1] = objy;
    in[2] = objz;
    in[3] = 1.0;
    
    gluMultMatrixVector3f(modelMatrix, in, out);
	
    gluMultMatrixVector3f(projMatrix, out, in);
	
    if (in[3] == 0.0)
        return(GL_FALSE);
	
    in[0] /= in[3];
    in[1] /= in[3];
    in[2] /= in[3];
	
    // Map x, y and z to range 0-1
    in[0] = in[0] * 0.5 + 0.5;
    in[1] = in[1] * 0.5 + 0.5;
    in[2] = in[2] * 0.5 + 0.5;
	
    // Map x,y to viewport
    in[0] = in[0] * viewport[2] + viewport[0];
    in[1] = in[1] * viewport[3] + viewport[1];
	
    *winx = in[0];
    *winy = in[1];
    *winz = in[3];
    
    return(GL_TRUE);
}

void gluGetScreenLocation(GLfloat xa, GLfloat ya, GLfloat za, GLfloat *sx, GLfloat *sy, GLfloat *sz)
{
    GLfloat mvmatrix[16];
    GLfloat projmatrix[16];
    GLfloat x,y,z;
    GLint viewport[4];
	
    glGetIntegerv(GL_VIEWPORT, viewport);
    glGetFloatv(GL_MODELVIEW_MATRIX, mvmatrix);
    glGetFloatv(GL_PROJECTION_MATRIX, projmatrix);
	
    gluProject(xa, ya, za, mvmatrix, projmatrix, viewport, &x, &y, &z);
	
    y = viewport[3] - y;
    
    *sx = x;
    *sy = y;
    
    if (sz != NULL)
        *sz=z;
}

void gluMultMatrixVector3f(const GLfloat matrix[16], const GLfloat in[4], GLfloat out[4])
{
    int i;
	
    for (i = 0; i < 4; i++)
    {
        out[i] =    in[0] * matrix[0*4+i] +
        in[1] * matrix[1*4+i] +
        in[2] * matrix[2*4+i] +
        in[3] * matrix[3*4+i];
    }
}

/*//  gluUnProject maps window coordinates to OpenGL world coordinates
GLint gluUnProject(GLfloat winx, GLfloat winy, GLfloat winz,
                   const GLfloat modelMatrix[16],
                   const GLfloat projMatrix[16],
                   const GLint viewport[4],
                   GLfloat *objx, GLfloat *objy, GLfloat *objz)
{
    GLfloat finalMatrix[16];
    float in[4];
    float out[4];
    
    gluMultMatricesd(modelMatrix, projMatrix, finalMatrix);
    
    if (!gluInvertMatrixd(finalMatrix, finalMatrix))
        return(GL_FALSE);
    
    in[0] = winx;
    in[1] = winy;
    in[2] = winz;
    in[3] = 1.0;
    
    // Map x and y from window coordinates 
    in[0] = (in[0] - viewport[0]) / viewport[2];
    in[1] = (in[1] - viewport[1]) / viewport[3];
    
    // Map to range -1 to 1 
    in[0] = in[0] * 2 - 1;
    in[1] = in[1] * 2 - 1;
    in[2] = in[2] * 2 - 1;
    
    gluMultMatrixVector3f(finalMatrix, in, out);
    
    if (out[3] == 0.0)
        return(GL_FALSE);
    
    out[0] /= out[3];
    out[1] /= out[3];
    out[2] /= out[3];
    
    *objx = out[0];
    *objy = out[1];
    *objz = out[2];
            
    return(GL_TRUE);
}

void gluGetOpenGLLocation(GLfloat xa, GLfloat ya, GLfloat za, GLfloat *sx, GLfloat *sy, GLfloat *sz)
{
    GLfloat mvmatrix[16];
    GLfloat projmatrix[16];
    GLfloat x, y, z;
    GLint viewport[4];
	
    glGetIntegerv(GL_VIEWPORT,viewport);
    glGetFloatv(GL_MODELVIEW_MATRIX,mvmatrix);
    glGetFloatv(GL_PROJECTION_MATRIX,projmatrix);
    
    gluUnProject(xa, ya, za, mvmatrix, projmatrix, viewport, &x, &y, &z);
    
    y = viewport[3] - y; // subtract Y coordinate from screen height
    
    *sx = x;
    *sy = y;
    
    glReadPixels(xa, viewport[3] - ya, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &sz); // get z component via depth buffer
}

void gluMultMatricesd(const GLfloat a[16], const GLfloat b[16], GLfloat r[16])
{
    int i, j;
    
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            r[i*4+j] =  a[i*4+0]*b[0*4+j] +
                        a[i*4+1]*b[1*4+j] +
                        a[i*4+2]*b[2*4+j] +
                        a[i*4+3]*b[3*4+j];
        }
    }
}

int gluInvertMatrixd(const GLfloat m[16], GLfloat invOut[16])
{
    double inv[16], det;
    int i;
    
    inv[0] =    m[5]*m[10]*m[15] - m[5]*m[11]*m[14] - m[9]*m[6]*m[15]
                + m[9]*m[7]*m[14] + m[13]*m[6]*m[11] - m[13]*m[7]*m[10];
                inv[4] =  -m[4]*m[10]*m[15] + m[4]*m[11]*m[14] + m[8]*m[6]*m[15]
                - m[8]*m[7]*m[14] - m[12]*m[6]*m[11] + m[12]*m[7]*m[10];
                inv[8] =   m[4]*m[9]*m[15] - m[4]*m[11]*m[13] - m[8]*m[5]*m[15]
                + m[8]*m[7]*m[13] + m[12]*m[5]*m[11] - m[12]*m[7]*m[9];
                inv[12] = -m[4]*m[9]*m[14] + m[4]*m[10]*m[13] + m[8]*m[5]*m[14]
                - m[8]*m[6]*m[13] - m[12]*m[5]*m[10] + m[12]*m[6]*m[9];
                inv[1] =  -m[1]*m[10]*m[15] + m[1]*m[11]*m[14] + m[9]*m[2]*m[15]
                - m[9]*m[3]*m[14] - m[13]*m[2]*m[11] + m[13]*m[3]*m[10];
                inv[5] =   m[0]*m[10]*m[15] - m[0]*m[11]*m[14] - m[8]*m[2]*m[15]
                + m[8]*m[3]*m[14] + m[12]*m[2]*m[11] - m[12]*m[3]*m[10];
                inv[9] =  -m[0]*m[9]*m[15] + m[0]*m[11]*m[13] + m[8]*m[1]*m[15]
                - m[8]*m[3]*m[13] - m[12]*m[1]*m[11] + m[12]*m[3]*m[9];
                inv[13] =  m[0]*m[9]*m[14] - m[0]*m[10]*m[13] - m[8]*m[1]*m[14]
                + m[8]*m[2]*m[13] + m[12]*m[1]*m[10] - m[12]*m[2]*m[9];
                inv[2] =   m[1]*m[6]*m[15] - m[1]*m[7]*m[14] - m[5]*m[2]*m[15]
                + m[5]*m[3]*m[14] + m[13]*m[2]*m[7] - m[13]*m[3]*m[6];
                inv[6] =  -m[0]*m[6]*m[15] + m[0]*m[7]*m[14] + m[4]*m[2]*m[15]
                - m[4]*m[3]*m[14] - m[12]*m[2]*m[7] + m[12]*m[3]*m[6];
                inv[10] =  m[0]*m[5]*m[15] - m[0]*m[7]*m[13] - m[4]*m[1]*m[15]
                + m[4]*m[3]*m[13] + m[12]*m[1]*m[7] - m[12]*m[3]*m[5];
                inv[14] = -m[0]*m[5]*m[14] + m[0]*m[6]*m[13] + m[4]*m[1]*m[14]
                - m[4]*m[2]*m[13] - m[12]*m[1]*m[6] + m[12]*m[2]*m[5];
                inv[3] =  -m[1]*m[6]*m[11] + m[1]*m[7]*m[10] + m[5]*m[2]*m[11]
                - m[5]*m[3]*m[10] - m[9]*m[2]*m[7] + m[9]*m[3]*m[6];
                inv[7] =   m[0]*m[6]*m[11] - m[0]*m[7]*m[10] - m[4]*m[2]*m[11]
                + m[4]*m[3]*m[10] + m[8]*m[2]*m[7] - m[8]*m[3]*m[6];
                inv[11] = -m[0]*m[5]*m[11] + m[0]*m[7]*m[9] + m[4]*m[1]*m[11]
                - m[4]*m[3]*m[9] - m[8]*m[1]*m[7] + m[8]*m[3]*m[5];
                inv[15] =  m[0]*m[5]*m[10] - m[0]*m[6]*m[9] - m[4]*m[1]*m[10]
                + m[4]*m[2]*m[9] + m[8]*m[1]*m[6] - m[8]*m[2]*m[5];
    
    det = m[0]*inv[0] + m[1]*inv[4] + m[2]*inv[8] + m[3]*inv[12];
    
    if (det == 0)
        return GL_FALSE;
    
    det = 1.0 / det;
    
    for (i = 0; i < 16; i++)
        invOut[i] = inv[i] * det;
    
    return GL_TRUE;
} */