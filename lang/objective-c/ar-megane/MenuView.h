// Code Linsence: MIT by akio0911
// http://d.hatena.ne.jp/akio0911/
// akio0911@gmail.com
//
//  MenuView.h
//  CocoaAnimeCamera
//
//  Created by ssatou on 08/04/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import	<QuartzCore/CoreAnimation.h>
#import <QTKit/QTKit.h>

// MenuViewクラスは、ウインドウに挿入されるビューの 
// サブクラスであり、rootLayerをホストしイベントに応答する 
@interface MenuView : NSView {

   // 選択されたメニュー項目インデックスを含む 
	NSInteger	selectedIndex; 

    // メニュー項目レイヤを含むレイヤ 
	CALayer	*menusLayer; 

   // メニュー項目名の配列
	NSArray	*names;
	
	QTCaptureSession           *mCaptureSession;
	QTCaptureDeviceInput       *mCaptureDeviceInput;
	
	CATextLayer *countLayer;
	CATextLayer *currentLocationLayer;
	CATextLayer *currentKakudoLayer;
	CALayer *akio0911Layer;
	CALayer *akio0911IconLayer;
	
	double mDirDig;

	QTCaptureLayer *rootLayer;
}

-(void)awakeFromNib; 
-(void)setupLayers; 
-(void)dealloc; 

@end
