//
//  CoinRecordListViewController.m
//  guangda
//
//  Created by Ray on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinRecordListViewController.h"
#import "CoinRecordListTableViewCell.h"
@interface CoinRecordListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation CoinRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"CoinRecordListTableViewCell";
    CoinRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CoinRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
