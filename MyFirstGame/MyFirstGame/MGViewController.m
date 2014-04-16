//
//  MGViewController.m
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import "MGViewController.h"
#import "MGCardCameViewController.h"
#import "MGCardData.h"
@interface MGViewController ()

@end

@implementation MGViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    imageDataCount = -1;
    _imageNameArray = [[NSMutableArray alloc]init];
}


- (IBAction)downloadCardDataBtnClicked:(id)sender {
    if(imageDataCount == -1){
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        //url
        NSURL *url = [[NSURL alloc] initWithString:@"http://itunes.apple.com/jp/rss/topfreeapplications/limit=10/json"];
        //request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        //connection
        if(_connection == nil){
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if(_connection){
                receivedData = [[NSMutableData alloc] init];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" message:@"이미 다운로드 되어있습니다." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
/** UIAlertViewのDelegate　基本は閉じるたけの機能*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
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
    [_cardDownloadStatusLabel setText:@"다운로드 실패"];
    imageDataCount = -1;
    _connection = nil;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(imageDataCount == -1){
        [receivedData appendData:data];
    }else{
        MGCardData *_data = [cardArray objectAtIndex:imageDataCount];
        [[_data cardData] appendData:data];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _connection = nil;
    
    if(imageDataCount == -1){
        //이미지다운받은 주소 취득을 위한 json데이터의 취득
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
        NSDictionary *feedDict = [jsonDictionary objectForKey:@"feed"];
        NSLog(@"feedDict count = %lu",(unsigned long)[feedDict count]);
        NSArray *entryArray = [feedDict objectForKey:@"entry"];
        NSLog(@"entryArray count = %lu",(unsigned long)[entryArray count]);
        
        for (int i = 0; i < [entryArray count]; ++i) {
            NSDictionary *entryItem = [entryArray objectAtIndex:i];
            NSArray *imageNameArray = [entryItem objectForKey:@"im:image"];
            NSDictionary *imageNameDict = [imageNameArray objectAtIndex:2];
            NSString *imageNameString = [imageNameDict objectForKey:@"label"];
            [_imageNameArray addObject:imageNameString];
        }
        //데이터를 전부 취득후 그 데이터를 가지고 이미지 다운로드를 시작합니다.
        if(_connection == nil){
            imageDataCount = 0;
            NSURL *url = [[NSURL alloc] initWithString:[_imageNameArray objectAtIndex:imageDataCount]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if(_connection){
                //제일 처음이므로 배열을 초기화하고 첫번째 데이터도 초기화합니다.
                cardArray = [[NSMutableArray alloc] init];
                MGCardData *data = [[MGCardData alloc] init];
                [data setCardTag:[[NSNumber alloc]  initWithInt:imageDataCount]];
                [data setCardData:[[NSMutableData alloc]init]];
                [cardArray addObject:data];
                
            }
        }
    }else{
        ++imageDataCount;
        if(_connection == nil && imageDataCount < 10){
            NSURL *url = [[NSURL alloc] initWithString:[_imageNameArray objectAtIndex:imageDataCount]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if(_connection){
                MGCardData *data = [[MGCardData alloc] init];
                [data setCardTag:[[NSNumber alloc]  initWithInt:imageDataCount]];
                [data setCardData:[[NSMutableData alloc]init]];
                [cardArray addObject:data];
            }
        }else{
            //ダウンロード完了
            [_cardDownloadStatusLabel setText:@"다운로드 완료"];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = NO;
        }
    }
}
//parsing

#pragma mark - Segue移動時のイベント
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    NSString *strSegueIdentifier = segue.identifier;
    
    if([strSegueIdentifier isEqualToString:@"cardGame"]) {
        MGCardCameViewController *vc = [segue destinationViewController];
        [vc setCardDataArray:cardArray];
        [vc.cardDataArray addObjectsFromArray:cardArray];
    }
}

@end
