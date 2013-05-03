//
//  miniGLU.h
//  miniGLU
//
//  Created by Taylor Triggs on 4/26/13.
//  Copyright 2013 Cal State Channel Islands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "CommonOpenGL.h"

void gluMultMatrixVector3f(const GLfloat matrix[16], const GLfloat in[4], GLfloat out[4]);

void gluGetScreenLocation(GLfloat xa, GLfloat ya, GLfloat za, GLfloat *sx, GLfloat *sy, GLfloat *sz);

GLint gluProject(GLfloat objx, GLfloat objy, GLfloat objz,
				 const GLfloat modelMatrix[16],
				 const GLfloat projMatrix[16],
				 const GLint   viewport[4],
				 GLfloat *winx, GLfloat *winy, GLfloat *winz);

/* 
int gluInvertMatrixd(const GLfloat m[16], GLfloat invOut[16]);

void gluMultMatricesd(const GLfloat a[16], const GLfloat b[16], GLfloat r[16]);
 
void gluGetOpenGLLocation(GLfloat xa, GLfloat ya, GLfloat za, GLfloat *sx, GLfloat *sy, GLfloat *sz);


GLint gluUnProject(GLfloat winx, GLfloat winy, GLfloat winz,
                   const GLfloat modelMatrix[16],
                   const GLfloat projMatrix[16],
                   const GLint viewport[4],
                   GLfloat *objx, GLfloat *objy, GLfloat *objz); */