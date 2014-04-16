//
//  MGViewController.h
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 3. 12..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGViewController : UIViewController<UIAlertViewDelegate>{
    /** カードの情報を保存するためのデータ*/
    NSMutableArray *cardArray;
    /** コネクション（複数リクエストを管理するため、基本は１つのコネクションを使い回します。）*/
    NSURLConnection *_connection;
    /** レスポンスデータの使い回し*/
    NSMutableData *receivedData;
    /** イメージダウンロード用のカウンター*/
    int imageDataCount;
    NSMutableArray *_imageNameArray;
}
- (IBAction)downloadCardDataBtnClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *cardDownloadStatusLabel;

@end
