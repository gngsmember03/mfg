//
//  MGCardCameViewController.h
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGCardCameViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>{
    
//    NSMutableArray *cardArray;
    int showedImageCount;
    
    int solvedCount;
    /** \brief 남은시간계산용 타이머**/
    NSTimer *timer_;
    /** \brief 남은시간계산용 숫자**/
    float count;
    /** \brief 풀이한 문제수**/
    int numberOfSolved;
    /** 뒤집은 카드의 태그번호*/
    NSNumber *displayedCardTag;
    /** 뒤집은 카드의 인덱스번호(틀리면 다시 뒤집기 위해서)*/
    NSIndexPath *beforeIndexPath;
    /** 처음 카드를 뒤집었는지 플래그*/
    BOOL isFirstTouch;
    
    NSURLConnection *_connection;
    NSMutableData *receivedData;
}
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *cardDataArray;
@property (strong, nonatomic) IBOutlet UILabel *solvedNumber;

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
- (IBAction)closeButtonClicked:(id)sender;


@end
