//
//  MGCalculateViewController.m
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import "MGCalculateViewController.h"
#import "CommonType.h"


@interface MGCalculateViewController ()

@end

@implementation MGCalculateViewController
#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timer_ = [NSTimer scheduledTimerWithTimeInterval:kIntervalTime
                                              target:self
                                            selector:@selector(updateTimer:)
                                            userInfo:nil
                                             repeats:YES];
    count = kRemainTime;
    numberOfSolved = 0;
    //첫번째 문제를 생성합니다.
    [self makeQuestion];
}
#pragma mark - Private Method
-(void)makeQuestion{
    
    //2자리수의 랜덤 숫자를 결정해서 라벨에 셋트합니다.
    int frontNumber = random() % 100;
    int backNumber = random() % 100;
    int temp = 0;
    if(frontNumber < backNumber){
        temp = backNumber;
        backNumber = frontNumber;
        frontNumber = temp;
    }
    [_frontQuizNumberLabel setText:[NSString stringWithFormat:@"%d",frontNumber]];
    [_backQuizNumberLabel setText:[NSString stringWithFormat:@"%d",backNumber]];
    
    int calType = random() % 3;//4의 경우 나눗셈까지 포함
    switch (calType) {
        case kCalculatorTypePlus:
            answerNumber = frontNumber + backNumber;
            [_centerMarkLabel setText:@"+"];
            break;
        case kCalculatorTypeMinus:
            answerNumber = frontNumber - backNumber;
            [_centerMarkLabel setText:@"-"];
            break;
        case kCalculatorTypeMultiply:
            answerNumber = frontNumber * backNumber;
            [_centerMarkLabel setText:@"*"];
            break;
        case kCalculatorTypeDivide://나누셈은 복잡하므로 일단 제외합니다.
            answerNumber = frontNumber / backNumber;
            [_centerMarkLabel setText:@"/"];
            break;
    }
}
//남은 시간을 갱신합니다.
-(void)updateTimer:(NSTimer*)timer{
    count -= kIntervalTime;
    if(count < 0){
        [timer_ invalidate];
        count = 0;
    }
    NSString *timeString = [NSString stringWithFormat:@"%.1f초",count];
    _timerLabel.text = timeString;
}

#pragma mark - Local Event
/*
- (IBAction)confirmButtonClicked:(id)sender {
    if(true){
        numberOfSolved += 1;
        _solveLabel.text = [NSString stringWithFormat:@"%d",numberOfSolved];
        if(numberOfSolved >= 3){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"클리어" message:@"문제를 다 풀었습니다." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setTag:100];
            [alertView show];
        }
    }
}
*/
- (IBAction)numberButtonClicked:(id)sender {
    NSInteger buttonNumber = [sender tag];
    NSLog(@"number = %d",buttonNumber-1000);
    int inputNumber = (int)buttonNumber-1000;
    
    if ([_answerNumberLabel.text isEqualToString:@"?"] || [_answerNumberLabel.text isEqualToString:@"0"]) {
        _answerNumberLabel.text = [NSString stringWithFormat:@"%d",inputNumber];
    }else{
        NSString *labelText = [_answerNumberLabel text];
        //세자릿수를 넘지 않을경우 숫자를 추가합니다.
        if([labelText length]<3){
            labelText = [labelText stringByAppendingString:[NSString stringWithFormat:@"%d",inputNumber]];
            [_answerNumberLabel setText:labelText];
        }
    }
}

- (IBAction)deleteButtonClicked:(id)sender {
    [_answerNumberLabel setText:@"0"];
}

- (IBAction)equalButtonClicked:(id)sender {
    int submitNumber = [_answerNumberLabel.text intValue];
    if(answerNumber == submitNumber){
        ++numberOfSolved;
        [self makeQuestion];
        [_answerNumberLabel setText:@"0"];
    }
    
    [_solveLabel setText:[NSString stringWithFormat:@"%d",numberOfSolved]];
    if(numberOfSolved >= 3){//세문제 이상을 맞추면 성공
        //서버에 관련 정보를 송신
        NSURL *url = [[NSURL alloc] initWithString:@"http://133.242.208.136/sampleJson01.json"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        
        if(connection == nil){
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if(connection){
                getHttpData = [[NSMutableData alloc] init];
            }
        }
        
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    
}

- (IBAction)passButtonClicked:(id)sender {
    [self makeQuestion];
    [_answerNumberLabel setText:@"0"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView tag] == 100){
        //서버 통신
        NSURL *url = [[NSURL alloc] initWithString:@"http://133.242.208.136/sampleJson01.json"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        
        if(connection == nil){
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if(connection){
                getHttpData = [[NSMutableData alloc] init];
            }
        }
    }else{
        switch (buttonIndex) {
            case 0://나가기
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case 1://다시하기
                NSLog(@"다시하기");
                break;
        }
    }
}
#pragma mark - Network Event
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [res statusCode];
    NSLog(@"statusCode = %ld",(long)statusCode);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [getHttpData appendData:data];
    NSString *str = [[NSString alloc] initWithData:getHttpData encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@",str);
    self->connection = nil;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:getHttpData options:0 error:nil];
    NSLog(@"%lu",(unsigned long)[jsonDictionary count]);
    NSNumber *stNumber = [jsonDictionary objectForKey:@"status"];
    NSLog(@"status = %@",stNumber);
    NSString *rankString = [jsonDictionary objectForKey:@"message"];
    NSLog(@"status = %@",rankString);
    NSString *title1 = [jsonDictionary objectForKey:@"title"];
    NSLog(@"status = %@",title1);
    NSString *rank = [NSString stringWithFormat:@"당신의 순위는 %@등입니다.",rankString];
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"순위" message:rank delegate:self cancelButtonTitle:@"나가기" otherButtonTitles:@"다시하기",nil];
    [alertView2 show];

}

@end
