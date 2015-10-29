//
//  ViewController.m
//  mapkit
//
//  Created by huangzhenyu on 15/5/19.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "locationGPS.h"
#import "CusAnnotationView.h"
#import "Myanotation.h"
#import "LocationManager.h"
#import "CheckBox.h"

#define kCalloutViewMargin          -8

@interface ViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)backClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;//经度
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;//纬度
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic,strong) CheckBox *checkBox;

// 搜索框
@property (nonatomic ,strong) UISearchBar *search;

// 筛选框
@property (nonatomic,strong ) UIButton    *selectButton;

// 下三角
@property (nonatomic ,strong) UIImageView *imageView;
// 保存下拉列表名称
@property (nonatomic,strong ) NSMutableArray *array;

// 第一次进地图,就创建一次checkBox
@property (nonatomic, assign) BOOL           isClick;
// 显示或隐藏checkBox  yes显示  no不显示
@property (nonatomic,assign ) BOOL           isShow;


@property (nonatomic,strong) NSMutableArray *images;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    locationGPS *loc = [locationGPS sharedlocationGPS];
    [loc getAuthorization];//授权
    [loc startLocation];//开始定位
    
    [self setNavigationbar];
    
    //跟踪用户位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    //地图类型
//    self.mapView.mapType = MKMapTypeSatellite;
    
    self.mapView.delegate = self;
}

- (void)setNavigationbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 64)];
    nav.tintColor = [UIColor blackColor];
    //创建UINavigationItem
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"附近的人"];
    [nav pushNavigationItem: navigationBarTitle animated:YES];
    [self.view addSubview:nav];
    //创建UIBarButton 可根据需要选择适合自己的样式
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"查看附近人" style:(UIBarButtonItemStylePlain) target:self action:@selector(checkOutFriend:)];

    //设置barbutton
    navigationBarTitle.rightBarButtonItem = item;
    [nav setItems:[NSArray arrayWithObject: navigationBarTitle]];
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_setupView];
    
}


- (void)p_setupView
{
    self.search                                = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 64, self.view.bounds.size.width - 10 - 90 - 10 - 10, 35)];
    self.search.backgroundColor                = [UIColor whiteColor];
    self.search.barStyle                       = UIBarStyleDefault;
    self.search.backgroundImage                = [UIImage imageNamed:@"空白"];
    // 设置独有的点击,不会传给父视图
    //    self.search.exclusiveTouch = YES;
    
    self.search.alpha                          = 0.8;
    self.search.placeholder                    = @"请输入景点,查看附近玩客";
    [self.mapView addSubview:_search];
    
    self.selectButton                          = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    self.selectButton.frame                    = CGRectMake(CGRectGetMaxX(self.search.frame) + 10, CGRectGetMinY(self.search.frame), 90, 35);
    self.selectButton.backgroundColor          = [UIColor whiteColor];
    [self.selectButton setTitle:@"筛选" forState:(UIControlStateNormal)];
    //    self.selectButton.exclusiveTouch = YES;
    self.selectButton.alpha                    = 0.8;
    self.selectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.selectButton addTarget:self action:@selector(checkBoxAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:_selectButton];
    
    UIImage *image                             = [UIImage imageNamed:@"sy-25"];
    self.imageView                             = [[UIImageView alloc] initWithImage:image];
    self.imageView.backgroundColor             = [UIColor clearColor];
    self.imageView.frame                       = CGRectMake(CGRectGetWidth(self.selectButton.frame) - 10, CGRectGetHeight(self.selectButton.frame) - 10, 10, 10);
    //    self.selectButton.imageView.userInteractionEnabled = YES;
    [self.selectButton addSubview:_imageView];
    
    self.array = [NSMutableArray arrayWithObjects:@"已认证",@"男",@"女",@"1km",@"5km",@"10km",@"20km", nil];
    
    [self initShowAndClick];
    
}

// 自适应方法






#warning 模拟附近好友的按钮 最后要删除
- (void)checkOutFriend:(UIBarButtonItem *)sender
{
    
    // 循环添加十个用户标签
    for (int i = 0 ; i < 10; i ++) {
        // 获取地图上点的坐标
        CLLocationCoordinate2D randomCoordinate = [self.mapView convertPoint:[self randomPoint] toCoordinateFromView:self.view];
        [self addAnnotationWithCooordinate:randomCoordinate];
    }
    
}


#warning  随机产生一个点(获取用户的经纬度)
- (CGPoint)randomPoint
{
    CGPoint randomPoint = CGPointZero;
    randomPoint.x       = arc4random() % (int)(CGRectGetWidth(self.view.bounds));
    randomPoint.y       = arc4random() % (int)(CGRectGetHeight(self.view.bounds));
    
    return randomPoint;
}


// 初始化图片数组(获取用户头像信息)
- (void)makeImages
{
    // 获取图片
    UIImage *image1 = [UIImage imageNamed:@"hema"];
    UIImage *image2 = [UIImage imageNamed:@"hehe"];
    UIImage *image3 = [UIImage imageNamed:@"haha"];
    
    // 把所有图片存入images数组中
    self.images = [NSMutableArray arrayWithObjects:image1,image2,image3, nil];
}


-(void)addAnnotationWithCooordinate:(CLLocationCoordinate2D)coordinate
{
    // 单个标签
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate         = coordinate;
    annotation.title              = @"AutoNavi";
    annotation.subtitle           = @"CustomAnnotationView";
    
    NSLog(@"addAnnotationWithCoorDinate--%@",annotation.title);
    
    [self.mapView addAnnotation:annotation];
    
}

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight  = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft   = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop    = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}


- (void)initShowAndClick
{
    self.isShow = YES;
    self.isClick = NO;
}

- (void)checkBoxAction
{
    NSLog(@"按钮的isclick值%d",self.isClick);
    if (!_isClick)
    {
        [self showCheckBox];
        _isClick = YES;
        
    }
    
    // 显示或隐藏
    if (_isShow) {
        [self show];
        _isShow = NO;
        NSLog(@"显示列表");
    }else
    {
        [self hidden];
        _isShow = YES;
        NSLog(@"隐藏列表");
    }
    
}

- (void)show
{
    CheckBox *temp = [[CheckBox alloc] init];
    for (int i = 0; i < 7; i ++) {
        temp = (CheckBox *)[self.mapView viewWithTag:100 + i];
        temp.hidden = NO;
    }
}

- (void)hidden
{
    CheckBox *temp = [[CheckBox alloc] init];
    
    for (int i = 0; i < 7; i ++) {
        
        temp = (CheckBox *)[self.mapView viewWithTag:100 + i];
        temp.hidden = YES;
        
    }
}

- (void)showCheckBox
{
    
    NSLog(@"要显示列表");
    
    NSInteger t = 0;
    for (int i = 0 ; i < 7; i ++) {
        
        self.checkBox = [[CheckBox alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.selectButton.frame), CGRectGetMaxY(self.selectButton.frame) + i * 35, CGRectGetWidth(self.selectButton.frame), 35)];
        _checkBox.delegate = self;
        
        _checkBox.layer.borderColor = (__bridge CGColorRef)([UIColor lightGrayColor]);
        _checkBox.layer.borderWidth = 1;
        _checkBox.backgroundColor = [UIColor whiteColor];
        
        _checkBox.tag = 100 + t++;
        
        [_checkBox setValue:self.array[i] withCode:@"name"];
        [self.mapView addSubview:_checkBox];
        
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.search resignFirstResponder];
    [self hidden];
    NSLog(@"点击地图,隐藏列表");
    self.isShow = YES;
}


/**
 * 当用户位置更新，就会调用
 *
 * userLocation 表示地图上面那可蓝色的大头针的数据
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    userLocation.title = [NSString stringWithFormat:@"经度：%f",center.longitude];
    userLocation.subtitle = [NSString stringWithFormat:@"纬度：%f",center.latitude];

//    NSLog(@"定位：%f %f --- %i",center.latitude,center.longitude,mapView.showsUserLocation);
    
//    if (mapView.showsUserLocation) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            //监听MapView点击
//            NSLog(@"添加监听");
//            [mapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
//        });
//    }
    
    
    //设置地图的显示范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.023666, 0.016093);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [mapView setRegion:region animated:YES];
    
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    //获取跨度
//    NSLog(@"%f  %f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    /*
    //如果是定位的大头针就不用自定义
//    if ([annotation isKindOfClass:[Myanotation class]]) {
//        static NSString *ID = @"anno";
//        MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
//        if (annoView == nil) {
//            annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
//        }
//        
//        Myanotation *anno = annotation;
//        annoView.image = [UIImage imageNamed:@"map_locate_blue"];
//        annoView.annotation = anno;
//        
//        return annoView;
//    }
     */
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        CusAnnotationView *annotationView = (CusAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil) {
            annotationView = [[CusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.draggable      = YES;
        annotationView.calloutOffset  = CGPointMake(0, -5);
        
        
        [self makeImages];
        // 随机生成图片
        annotationView.portrait       = [UIImage imageNamed:@"hehe"];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView--%@",view);
    
    if ([view isKindOfClass:[CusAnnotationView class]]) {
        CusAnnotationView *cusView = (CusAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];

        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
////        if (!CGRectContainsRect(self.mapView.frame, frame))
////        {
//            /* Calculate the offset to make the callout view show up.
//             calculate the offset to make the callout view show up.
//             */
//            
//            // 计算偏移量 显示callout视图
////            CGSize offset                     = [self offsetToContainRect:frame inRect:self.mapView.frame];
//            // 屏幕锚点的位置
////            CGPoint screenAnchor              = [[self.mapView getMapStatus].screenAnchor ];
////            CGPoint theCenter                 = CGPointMake(self.mapView.bounds.size.width *screenAnchor.x, self.mapView.bounds.size.height *screenAnchor.y);
////            theCenter                         = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
////            // 让地图视图现在中心点上
////            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
////            // 设置地图中心点
////            [self.mapView setCenterCoordinate:coordinate animated:YES];
////        }
    }


    
    
    
    
}

- (IBAction)backClick:(UIButton *)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

//- (void)tap:(UITapGestureRecognizer *)tap
//{
//    CGPoint touchPoint = [tap locationInView:tap.view];
//    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
//    
//    NSLog(@"%@",self.mapView.annotations);
//    NSMutableArray *array = [NSMutableArray array];
//    NSUInteger count = self.mapView.annotations.count;
//    if (count > 1) {
//        for (id obj in self.mapView.annotations) {
//            if (![obj isKindOfClass:[MKUserLocation class]]) {
//                [array addObject:obj];
//            }
//        }
//        [self.mapView removeAnnotations:array];
//    }
//    MKUserLocation *locationAnno = self.mapView.annotations[0];
//    
//    Myanotation *anno = [[Myanotation alloc] init];
//    
//    anno.coordinate = coordinate;
//    anno.title = [NSString stringWithFormat:@"经度：%f",coordinate.longitude];
//    anno.subtitle = [NSString stringWithFormat:@"纬度：%f",coordinate.latitude];
//    
//    self.longitudeLabel.text = [NSString stringWithFormat:@"经度：%f",coordinate.longitude];
//    self.latitudeLabel.text = [NSString stringWithFormat:@"纬度：%f",coordinate.latitude];
//    //反地理编码
//    LocationManager *locManager = [[LocationManager alloc] init];
//    [locManager reverseGeocodeWithlatitude:coordinate.latitude longitude:coordinate.longitude success:^(NSString *address) {
//        self.addressLabel.text = [NSString stringWithFormat:@"%@",address];
//    } failure:^{
//        
//    }];
//    
//    //距离
//    double distance = [locManager countLineDistanceDest:coordinate.longitude dest_Lat:coordinate.latitude self_Lon:locationAnno.coordinate.longitude self_Lat:locationAnno.coordinate.latitude];
//    self.distanceLabel.text = [NSString stringWithFormat:@"距您%d米",(int)distance];
//    
//    [self.mapView addAnnotation:anno];
//}



@end
