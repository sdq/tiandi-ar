//
//  ARView.m
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "ARView.h"

#pragma mark -
#pragma mark Math utilities declaration

#define DEGREES_TO_RADIANS (M_PI/180.0)

static NSString * const kUUID = @"d26d197e-4a1c-44ae-b504-dd7768870564";


typedef float mat4f_t[16];	// 4x4 matrix in column major order
typedef float vec4f_t[4];	// 4D vector

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);

#pragma mark -
#pragma mark Geodetic utilities declaration

#define WGS84_A	(6378137.0)				// WGS 84 semi-major axis constant in meters
#define WGS84_E (8.1819190842622e-2)	// WGS 84 eccentricity

//// Converts latitude, longitude to ECEF coordinate system
//void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z);
//
//// Coverts ECEF to ENU coordinates centered at given lat, lon
//void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u);

// Converts xy on map to NEU coordinate system
void xyToNEU(double x0, double y0,  double x1, double y1, double orientation, double *e, double *n);

#pragma mark -
#pragma mark ARView extension

@interface ARView () {
	UIView *captureView;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *captureLayer;
	
	CADisplayLink *displayLink;
	CMMotionManager *motionManager;
    
    CLLocationManager *locationManager;
    int locationIndex;
    int lastLocationIndex;
    CGPoint location;
    float offset;
    CLBeaconRegion *beaconRegion;
    NSArray *coodinateData;
    
    BOOL shakeOrNot;
    
	NSArray *POIs;
	mat4f_t projectionTransform;
	mat4f_t cameraTransform;
	vec4f_t *POIsCoordinates;
    
    UIImage *mapImage;
    UIImage *positionImage;
    CGImageRef cgMapImage;
    CGImageRef cgPositionImage;
    CGContextRef context;
    CGRect MapRect;
    CGRect PositionRect;
    double pitch,roll;
    
    InfoView *infoView;
    MapView *mapView;
}
@end

@implementation ARView

#pragma mark - basic

- (void)initialize
{
	captureView = [[UIView alloc] initWithFrame:self.bounds];
	captureView.bounds = self.bounds;
	[self addSubview:captureView];
	[self sendSubviewToBack:captureView];
    
    /**
     * add map surface
     */
    mapView = [[MapView alloc] init];
    [mapView.Map setImage:[UIImage imageNamed:@"map.jpg"]];
    [self addSubview:mapView];
    [self bringSubviewToFront:mapView];
    
    //get map context
    UIGraphicsBeginImageContextWithOptions(mapView.Map.image.size, YES, 0);
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, mapView.Map.image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    /**
     * add info surface
     */
    infoView = [[InfoView alloc] initWithFrame:CGRectMake(0, 528, 320, 40)];
    [infoView setBackgroundColor:[UIColor blackColor]];
    [infoView setAlpha:0.5];
    [self addSubview:infoView];
    [self bringSubviewToFront:infoView];
    
    // Initialize projection matrix
    createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 1000.0f);
    
    /**
     * preparation
     **/
    lastLocationIndex = -1;
    shakeOrNot = NO;
    offset = 7*M_PI/5;//set offset
    
    //for demo
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"coordinates" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSMutableArray *tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=0; j<[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    coodinateData = [tmpDataArray copy];
    
    locationIndex = 4;
    location.x = [[[coodinateData objectAtIndex:locationIndex] objectForKey:@"x"] floatValue];
    location.y = [[[coodinateData objectAtIndex:locationIndex] objectForKey:@"y"] floatValue];
    [self drawThePosition:location onMap:@"map.jpg"];
    [self updatePOIsCoordinates];
}

- (void)start
{
	[self startCameraPreview:AVCaptureDevicePositionBack];
    [self startLocation];
    [self startDeviceMotion];
	[self startDisplayLink];
}

- (void)startFrontCameraMode
{
    infoView.hidden = YES;
    mapView.hidden = YES;
    for (POI *poi in [POIs objectEnumerator]) {
		poi.view.hidden = YES;
	}
    [self stopCameraPreview];
    [self startCameraPreview:AVCaptureDevicePositionFront];
    [self stopLocation];
    [self stopDeviceMotion];
}

- (void)stop
{
	[self stopCameraPreview];
    [self stopLocation];
    [self stopDeviceMotion];
	[self stopDisplayLink];
}

- (void)stopFrontCameraMode
{
    [self stopCameraPreview];
    [self startCameraPreview:AVCaptureDevicePositionBack];
	[self startLocation];
    [self startDeviceMotion];
}

- (void)setPOIs:(NSArray *)pois
{
	for (POI *poi in [POIs objectEnumerator]) {
		[poi.view removeFromSuperview];
	}
    POIs = pois;
    
	//[self updatePOIsCoordinates];
}

#pragma mark - camera

- (void)startCameraPreview:(NSInteger)AVCaptureDevicePosition
{
	AVCaptureDevice* camera = [self cameraWithPosition:AVCaptureDevicePosition];
	if (camera == nil) {
		return;
	}
	
	captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	[captureSession addInput:newVideoInput];
	
	captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	captureLayer.frame = captureView.bounds;
    //	[captureLayer setOrientation:AVCaptureVideoOrientationPortrait];
	[captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[captureView.layer addSublayer:captureLayer];
	
	// Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[captureSession startRunning];
	});
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)stopCameraPreview
{
	[captureSession stopRunning];
	[captureLayer removeFromSuperlayer];
	captureSession = nil;
	captureLayer = nil;
}

#pragma mark - indoor location

- (void)startLocation
{
    //initialize beacon region
    [self initRegion];
    //load plist of coordinates
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"coordinates" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSMutableArray *tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=0; j<[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    coodinateData = [tmpDataArray copy];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startRangingBeaconsInRegion:beaconRegion];
    
}

- (void)initRegion
{
    if (beaconRegion)
        return;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    //    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"TongjiIdentifier"];
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"TongjiIdentifier"];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //CLBeacon *beacon = [[CLBeacon alloc] init];
    //beacon = [beacons lastObject];
    for(CLBeacon *beacon in beacons)
    {
        if (beacon.proximity != CLProximityUnknown){
            locationIndex = [[beacon minor] intValue];
            //refresh the map and POI only when the location changes
            if (lastLocationIndex!=locationIndex) {
                shakeOrNot = NO;//reset when location changes
                
                location.x = [[[coodinateData objectAtIndex:locationIndex] objectForKey:@"x"] floatValue];
                location.y = [[[coodinateData objectAtIndex:locationIndex] objectForKey:@"y"] floatValue];
                [self drawThePosition:location onMap:@"map.jpg"];
                
                [self updatePOIsCoordinates];
                
                NSString *locationInfoString;
                switch (locationIndex) {
                    case 4:
                        locationInfoString = @"您所在的位置：大厅";
                        break;
                        
                    default:
                        break;
                }
                
                infoView.InfoText.text = locationInfoString;
            }
            break;
        }
    }
}

#pragma mark - draw the map and position

- (void)drawThePosition:(CGPoint)position onMap:(NSString *)map{
    
    //map
    mapImage = [UIImage imageNamed:map];
    MapRect = CGRectMake(0, 0, mapView.Map.image.size.width, mapView.Map.image.size.height);
    cgMapImage = mapImage.CGImage;
    CGContextDrawImage(context, MapRect, cgMapImage);
    
    //position
    float x = position.x;
    float y = position.y;
    positionImage = [UIImage imageNamed:@"position.png"];
    PositionRect =  CGRectMake(x-150, y-150, 300, 300);
    cgPositionImage = positionImage.CGImage;
    CGContextDrawImage(context, PositionRect, cgPositionImage);
    
    mapImage = UIGraphicsGetImageFromCurrentImageContext();
    mapView.Map.image = mapImage;
    
}

-(void)updatePOIsCoordinates
{
    for (POI *poi in [POIs objectEnumerator]) {
		[poi.view removeFromSuperview];
	}
    
    if (POIsCoordinates != NULL) {
		free(POIsCoordinates);
	}
	POIsCoordinates = (vec4f_t *)malloc(sizeof(vec4f_t)*POIs.count);
    
	int i = 0;
    
	// Array of NSData instances, each of which contains a struct with the distance to a POI and the
	// POI's index into placesOfInterest
	// Will be used to ensure proper Z-ordering of UIViews
	typedef struct {
		float distance;
		int index;
	} DistanceAndIndex;
	NSMutableArray *orderedDistances = [NSMutableArray arrayWithCapacity:POIs.count];
    
	// Compute the coordinates
	for (POI *poi in [POIs objectEnumerator]) {
        double e, n;
        
        xyToNEU(location.x, location.y, poi->location.x, poi->location.y, offset, &e, &n );
        
        POIsCoordinates[i][0] = (float)n;
        POIsCoordinates[i][1]= -(float)e;
        POIsCoordinates[i][2] = 0.0f;
        POIsCoordinates[i][3] = 1.0f;
        
        // Add struct containing distance and index to orderedDistances
        DistanceAndIndex distanceAndIndex;
        distanceAndIndex.distance = sqrtf(n*n + e*e);
        distanceAndIndex.index = i;
        [orderedDistances insertObject:[NSData dataWithBytes:&distanceAndIndex length:sizeof(distanceAndIndex)] atIndex:i++];
		
	}
	
	// Sort orderedDistances in ascending order based on distance from the user
	[orderedDistances sortUsingComparator:(NSComparator)^(NSData *a, NSData *b) {
		const DistanceAndIndex *aData = (const DistanceAndIndex *)a.bytes;
		const DistanceAndIndex *bData = (const DistanceAndIndex *)b.bytes;
		if (aData->distance < bData->distance) {
			return NSOrderedAscending;
		} else if (aData->distance > bData->distance) {
			return NSOrderedDescending;
		} else {
			return NSOrderedSame;
		}
	}];
	
	// Add subviews in descending Z-order so they overlap properly
	for (NSData *d in [orderedDistances reverseObjectEnumerator]) {
		const DistanceAndIndex *distanceAndIndex = (const DistanceAndIndex *)d.bytes;
		POI *poi = (POI *)[POIs objectAtIndex:distanceAndIndex->index];
        
        //遍历所有POI.plist中数据，如果belongto中包含当前Index则显示出来
        //需要判断当前index是否在belongTolocationArray之中
        NSArray *belongToArrayToCheck = poi->belogToLocationArray;
        
        NSNumber *locationIndexNumber = [[NSNumber alloc]initWithInt:locationIndex];
        
        
        if ([belongToArrayToCheck containsObject:locationIndexNumber]&&(poi->shakedOrNot==shakeOrNot)) {
            [self addSubview:poi.view];//add specific subview according to the location
        }
	}
}

- (void)stopLocation
{
    [locationManager stopRangingBeaconsInRegion:beaconRegion];
    locationManager = nil;
}


#pragma mark - motion

- (void)startDeviceMotion
{
	motionManager = [[CMMotionManager alloc] init];
	
	// Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
	motionManager.showsDeviceMovementDisplay = YES;
	
	motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
	
	// New in iOS 5.0: Attitude that is referenced to true north
	[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
}

- (void)stopDeviceMotion
{
	[motionManager stopDeviceMotionUpdates];
	motionManager = nil;
}

#pragma mark - refresh view

- (void)startDisplayLink
{
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
	[displayLink setFrameInterval:1];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink
{
	[displayLink invalidate];
	displayLink = nil;
}

- (void)onDisplayLink:(id)sender
{
	CMDeviceMotion *d = motionManager.deviceMotion;
	if (d != nil) {
		CMRotationMatrix r = d.attitude.rotationMatrix;
		transformFromCMRotationMatrix(cameraTransform, &r);
		[self setNeedsDisplay];
	}
}

#pragma mark - UIView drawRect
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void)drawRect:(CGRect)rect
{
    pitch = motionManager.deviceMotion.attitude.pitch;
    roll = motionManager.deviceMotion.attitude.roll;
    
    //利用自带参数判断手机姿态，得出需要旋转的角度
    CGFloat rotationDegrees;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    switch (curDeviceOrientation) {
		case UIDeviceOrientationPortrait:
			rotationDegrees = 0;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			rotationDegrees = M_PI;
			break;
		case UIDeviceOrientationLandscapeLeft:
			rotationDegrees = M_PI_2;
			break;
		case UIDeviceOrientationLandscapeRight:
			rotationDegrees = -M_PI_2;
			break;
		default:
			break; // leave the layer in its last known orientation
	}
    
    
    if ((pitch<0.3)&&(pitch>-0.3)&&(roll<0.3)&&(roll>-0.3)) {
        mapView.hidden = NO;
        infoView.hidden = YES;
        mapView.center = CGPointMake(20,40);
    } else {
        mapView.hidden = YES;
        infoView.hidden = NO;
    }
    
    
	if (POIsCoordinates == nil) {
		return;
	}
	
	mat4f_t projectionCameraTransform;
	multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
	
	int i = 0;
	for (POI *poi in [POIs objectEnumerator]) {
        vec4f_t v;
        multiplyMatrixAndVector(v, projectionCameraTransform, POIsCoordinates[i]);
        
        float x = (v[0] / v[3] + 1.0f) * 0.5f;
        float y = (v[1] / v[3] + 1.0f) * 0.5f;
        if (v[2] < 0.0f) {
            poi.view.center = CGPointMake(x*self.bounds.size.width, self.bounds.size.height-y*self.bounds.size.height);
            poi.view.hidden = NO;
        } else {
            poi.view.hidden = YES;
        }
        
        //转换旋转坐标系
        CGAffineTransform t = CGAffineTransformMakeRotation(rotationDegrees);
        poi.view.transform = t;
        
		i++;
	}
    
}

#pragma mark - take screenshot

- (UIImage *)takeScreenshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - setShakeOrNot

- (void)setShakeOrNot:(BOOL)yesOrNot
{
    shakeOrNot = yesOrNot;
    [self updatePOIsCoordinates];
}

#pragma mark -
#pragma mark Math utilities definition

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
	float f = 1.0f / tanf(fovy/2.0f);
	
	mout[0] = f / aspect;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = (zFar+zNear) / (zNear-zFar);
	mout[11] = -1.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 2 * zFar * zNear /  (zNear-zFar);
	mout[15] = 0.0f;
}

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
	vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
	vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
	vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
	vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
	uint8_t col, row, i;
	memset(c, 0, 16*sizeof(float));
	
	for (col = 0; col < 4; col++) {
		for (row = 0; row < 4; row++) {
			for (i = 0; i < 4; i++) {
				c[col*4+row] += a[i*4+row]*b[col*4+i];
			}
		}
	}
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
	mout[0] = (float)m->m11;
	mout[1] = (float)m->m21;
	mout[2] = (float)m->m31;
	mout[3] = 0.0f;
	
	mout[4] = (float)m->m12;
	mout[5] = (float)m->m22;
	mout[6] = (float)m->m32;
	mout[7] = 0.0f;
	
	mout[8] = (float)m->m13;
	mout[9] = (float)m->m23;
	mout[10] = (float)m->m33;
	mout[11] = 0.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
}

#pragma mark -
#pragma mark Geodetic utilities definition

// Converts xy on map to NEU coordinate system
void xyToNEU(double x0, double y0, double x1, double y1, double offset, double *e, double *n)
{
    *e = (x0-x1)*cos(offset)+(y0-y1)*sin(offset);
    *n = -(x0-x1)*sin(offset)+(y0-y1)*cos(offset);
}



@end
