//
//  MGCardCameViewController.m
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import "MGCardCameViewController.h"
#import "CommonType.h"
#import "MGCardData.h"

@interface MGCardCameViewController ()

@end

@implementation MGCardCameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [self startGame];
}
/** 게임을 시작하는 부분입니다.(다시하기를 위한 임시대응)*/
-(void)startGame{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYYMMdd_HHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    NSLog(@"%@",dateString);
    for (int i = 0; i < [_cardDataArray count]; ++i) {
        MGCardData *cardData = [_cardDataArray objectAtIndex:i];
        [cardData setCardTag:[NSNumber numberWithInt:i]];
    }
    NSLog(@"_cardDataArray count = %lu",(unsigned long)[_cardDataArray count]);
    [self shuffle];
    
    timer_ = [NSTimer scheduledTimerWithTimeInterval:kIntervalTime
                                              target:self
                                            selector:@selector(updateTimer:)
                                            userInfo:nil
                                             repeats:YES];
    //    count = kRemainTime;
    numberOfSolved = 0;
    isFirstTouch = YES;
    beforeIndexPath = nil;
    displayedCardTag = nil;
    [_collectionView reloadData];
}
//카드 섞는 로직
- (void)shuffle
{
    NSUInteger cardCount = [_cardDataArray count];
    for (NSUInteger i = 0; i < cardCount; ++i) {
        NSInteger nElements = cardCount - i;
        NSInteger n = arc4random_uniform((int)nElements) + i;
        [_cardDataArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}
//남은 시간을 갱신합니다.
-(void)updateTimer:(NSTimer*)timer{
    count += kIntervalTime;
    if(count < 0){
        [timer_ invalidate];
        count = 0;
    }
    NSString *timeString = [NSString stringWithFormat:@"%.1f초",count];
    _timerLabel.text = timeString;
}
//컬렉션뷰의 자식 숫자
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _cardDataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    MGCardData *cardData = [_cardDataArray objectAtIndex:[indexPath row]];
    NSMutableData *imageData = [cardData cardData];
    
    UIImage *image = [UIImage imageWithData:imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, [cell contentView].frame.size.width, [cell contentView].frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [[cell contentView] addSubview:imageView];
    [[cell contentView] setHidden:YES];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"row = %lu",(long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [[cell contentView] setHidden:NO];
    MGCardData *cardData = [_cardDataArray objectAtIndex:[indexPath row]];
    NSLog(@"%@",[cardData cardTag]);
    //이미 뒤집은 카드라면은 선택을 패스합니다.
    if([[cardData cardTag] isEqual:[[NSNumber alloc] initWithInt:-1]]){
        return;
    }
    if(!isFirstTouch){
        if([displayedCardTag isEqual:[cardData cardTag]] && ![beforeIndexPath isEqual:indexPath]){
            //카드의 태그번호가 이전에 선택한 카드와 같다면 정답이기에 선택된 카드를 그냥 놔둔다
            [_solvedNumber setText:[NSString stringWithFormat:@"%d",++solvedCount]];
            [cardData setCardTag:[[NSNumber alloc]  initWithInt:-1]];
        }else{
            UICollectionViewCell *beforeCell = [collectionView cellForItemAtIndexPath:beforeIndexPath];
            //틀리기 때문에 다시 뒤집기
            [[beforeCell contentView] setHidden:YES];
            [[cell contentView] setHidden:YES];
        }
        isFirstTouch = YES;
    }else{
        isFirstTouch = NO;
        //첫번째 터치라면 뒤집고 그 번호를 저장한다
        beforeIndexPath = indexPath;
        //카드 확인용 태그
        displayedCardTag = [cardData cardTag];
    }
    //문제풀이 수가 10이 된다면 다 맞췄다는 이야기이므로 맞춘 시간을 서버에 전송합니다.
    if(solvedCount >= 1){
        //타이머를 멈추게 합니다.
        [timer_ invalidate];
        [self sendRankInfo];
    }

}
//성공한 시간을 서버에 전송합니다.
-(void)sendRankInfo{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    //url
    NSString *urlString = @"http://huhusoft.net/mfg/";
    //api주소를 추가합니다.
    urlString = [urlString stringByAppendingString:@"api/card/rank/upload/?"];
    urlString = [urlString stringByAppendingString:@"userId=3&"];
    urlString = [urlString stringByAppendingString:@"userName=Jaesung&"];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"time=%f&",count]];
    urlString = [urlString stringByAppendingString:@"apiKey=12345666&"];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYYMMdd_HHmmss"];
    
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    NSLog(@"%@",dateString);
    
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"uploadDate=%@",dateString]];
    NSLog(@"urlString = %@",urlString);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    //request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    //connection
    if(_connection == nil){
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(_connection){
            receivedData = [[NSMutableData alloc] init];
        }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}
//getResponse
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [res statusCode];
    NSLog(@"statusCode = %lu",(long)statusCode);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error!!! %lu",(long)[error code]);
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    _connection = nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _connection = nil;
    NSString *result = [[NSString alloc] initWithData:receivedData
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"resultString %@",result);
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
    NSNumber *rankNumber = [jsonDictionary objectForKey:@"rank"];
    NSNumber *statusNumber = [jsonDictionary objectForKey:@"status"];
    NSLog(@"rankNumber = %@",rankNumber);
    NSLog(@"statusNumber = %@",statusNumber);
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"당신의 순위는 !!" message:[NSString stringWithFormat:@"%@위입니다.",rankNumber] delegate:self cancelButtonTitle:@"돌아가기" otherButtonTitles:@"다시하기", nil];
    [alertView show];
}
- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonIndex = %d",buttonIndex);
    switch (buttonIndex) {
        case 0://cancel button
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            [self startGame];
            break;
    }
}
@end
