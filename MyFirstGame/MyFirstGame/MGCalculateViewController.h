//
//  MGCalculateViewController.h
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CalculatorType{
    kCalculatorTypePlus = 0
    ,kCalculatorTypeMinus
    ,kCalculatorTypeMultiply
    ,kCalculatorTypeDivide
};

@interface MGCalculateViewController : UIViewController{
    /** \brief 남은시간계산용 타이머**/
    NSTimer *timer_;
    /** \brief 남은시간계산용 숫자**/
    float count;
    /** \brief 풀이한 문제수**/
    int numberOfSolved;
    
    int answerNumber;
    /** \brief 랭킹서버데이터 취득용 데이터**/
    NSMutableData *getHttpData;
    /** \brief 랭킹서버 연결용 커넥션**/
    NSURLConnection *connection;
}
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
//- (IBAction)confirmButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *solveLabel;
@property (strong, nonatomic) IBOutlet UILabel *frontQuizNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *backQuizNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *centerMarkLabel;
@property (strong, nonatomic) IBOutlet UILabel *answerNumberLabel;
- (IBAction)numberButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)equalButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)passButtonClicked:(id)sender;
@end
