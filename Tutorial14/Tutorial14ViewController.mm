//
//  Tutorial14ViewController.m
//  Tutorial14
//
//  Created by Mike Daley on 20/03/2011.
//  Copyright 2011 Personal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Tutorial14ViewController.h"
#import "EAGLView.h"

@interface Tutorial14ViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;

// Init OpenGL ES ready to render in 3D
- (void)initOpenGLES1;

// Init the game objects and ivars
- (void)initGame;

// Update the scene
- (void)updateWithDelta:(float)aDelta;

// Render the scene
- (void)drawFrame;

// Manages the game loop and as called by the displaylink
- (void)gameLoop;

@end

@implementation Tutorial14ViewController

@synthesize animating, context, displayLink;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    // Init game
    [self initGame];
}

- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
        
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    // Init OpenGL ES 1
    [self initOpenGLES1];
    
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;
}

- (void)viewDidLoad
{

}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(gameLoop)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)initGame
{
    // Generate the floors vertices
    GLfloat z = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        zFloorVertices[index].x = -20.0;
        zFloorVertices[index].y = -1;
        zFloorVertices[index].z = z;
        
        zFloorVertices[index+1].x = 20.0;
        zFloorVertices[index+1].y = -1;
        zFloorVertices[index+1].z = z;
        
        z += 2.0f;
    }
    
    GLfloat x = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        xFloorVertices[index].x = x;
        xFloorVertices[index].y = -1;
        xFloorVertices[index].z = -20.0f;
        
        xFloorVertices[index+1].x = x;
        xFloorVertices[index+1].y = -1;
        xFloorVertices[index+1].z = 20;
        
        x += 2.0f;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
        NSLog(@"retina");
    
    else
        NSLog(@"not retina");
}

#pragma mark -
#pragma mark Game Loop

#define MAXIMUM_FRAME_RATE 90.0f
#define MINIMUM_FRAME_RATE 30.0f
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

- (void)gameLoop 
{
	static double lastFrameTime = 0.0f;
	static double cyclesLeftOver = 0.0f;
	double currentTime;
	double updateIterations;
	
	// Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
	// network time and so could change causing hiccups.
	currentTime = CACurrentMediaTime();
	updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);
	
	if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
		updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);
	
	while (updateIterations >= UPDATE_INTERVAL) 
    {
		updateIterations -= UPDATE_INTERVAL;
		
		// Update the game logic passing in the fixed update interval as the delta
		[self updateWithDelta:UPDATE_INTERVAL];		
	}
	
	cyclesLeftOver = updateIterations;
	lastFrameTime = currentTime;
    
    // Render the frame
    [self drawFrame];
}

#pragma mark -
#pragma mark Update

- (void)updateWithDelta:(float)aDelta
{
    angle += 0.5f;
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
    // Replace the implementation of this method to do your own custom drawing.
    static const GLfloat squareVertices[] = {
        -0.33f, -0.33f, 0.0f,
        0.33f, -0.33f, 0.0f,
        -0.33f,  0.33f, 0.0f,
        0.33f,  0.33f, 0.0f
    };
    
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
////////////  3D
    
    
    CGSize layerSize = self.view.layer.frame.size;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    gluPerspective(45.0f, (GLfloat)layerSize.width / (GLfloat)layerSize.height, 0.1f, 750.0f);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // Position the camera back from the origin and slightly raised i.e. {0, 3, -6}
    static GLfloat z = 0;
    gluLookAt(0, 5 + (sinf(z)/2.0f), -10, 0, 0, 0, 0, 1, 0);
    z += 0.075f;
    
    // Rotate the scene
    glRotatef(angle, 0, 1, 0);
    
    // Draw Grid
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glDisableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, zFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    glVertexPointer(3, GL_FLOAT, 0, xFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    GLfloat xPos, yPos, zPos, sx, sy, sz;
    
    xPos = 1.0f;
    yPos = 0.5f;
    zPos = 0.0f;
    
    glPushMatrix();
        glTranslatef(xPos, yPos, zPos);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glPopMatrix();
    
    // Get the current position of the drawn object and find the window coordinate position
    gluGetScreenLocation(xPos, yPos, zPos, &sx, &sy, &sz);
    
    GLfloat mvmatrix[16];
    GLfloat projmatrix[16];
    GLint viewport[4];
	
    glGetIntegerv(GL_VIEWPORT,viewport);
    glGetFloatv(GL_MODELVIEW_MATRIX,mvmatrix);
    glGetFloatv(GL_PROJECTION_MATRIX,projmatrix);
    
    // NOTE: gluUnproject doesn't work correctly, returns strange values
    //gluUnProject(103.637695, 88.764099, 10.285913, mvmatrix, projmatrix, viewport,&sx, &sy, &sz);
    
    //gluGetOpenGLLocation(108.14, 240, 11.18, &sx, &sy, &sz);
    
    NSLog(@"x:  %f     y:  %f    z: %f    ", sx, sy, sz);

    
////////////  2D
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glOrthof(0, rect.size.width, 0, rect.size.height, -15, 15);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glEnable(GL_TEXTURE_2D);
 
    // Draw the image to the window coordinates retrived from gluGetScreenLocation
    // NOTE: we must subtract sy from the height of the screen to properly map the image
    //       because the CGPointMake coordinates (0,0 top left) are different than the
    //       OpenGL ES coordinates (0,0 bottom left)
    [screen_location renderAtPoint:CGPointMake(sx, rect.size.height - sy) centerOfImage:YES];
        
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)initOpenGLES1
{
    // Set the clear color
    glClearColor(0, 0, 0, 1.0f);
    
    // Projection Matrix config
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    CGSize layerSize = self.view.layer.frame.size;
    gluPerspective(45.0f, (GLfloat)layerSize.width / (GLfloat)layerSize.height, 0.1f, 750.0f);
    
    // Modelview Matrix config
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // This next line is not really needed as it is the default for OpenGL ES
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
    
    // Enable depth testing
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    
    screen_location = [[Image alloc] initWithImage:[UIImage imageNamed:@"x_mark.png"] filter:GL_LINEAR];
    [screen_location setScale:0.07f];
    [screen_location setAlpha:0.5f];
}

@end