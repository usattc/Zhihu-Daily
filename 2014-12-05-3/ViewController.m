//
//  ViewController.m
//  2014-12-05-3
//
//  Created by TTC on 12/5/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "ViewController.h"
#import "Defines.h"
#import "CustomImageView.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NewsCell.h"
#import "DetailViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CustomImageViewDelegate> {
    UITableView *_tableView;
    UIScrollView *_scrollView;
    
    NSMutableArray *_dataList;
    NSArray *_topDataList;
    
    NSTimer *_timer;
    UIRefreshControl *_refreshControl;
}

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataList = [NSMutableArray array];
    
    [self initTableView];
    [self getDataList];
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中..."];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
}

- (void)getDataList {
    [[AFHTTPRequestOperationManager manager] GET:@"http://news-at.zhihu.com/api/3/news/latest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"result:%@", responseObject);
        [_dataList addObjectsFromArray:responseObject[@"stories"]];
        _topDataList = responseObject[@"top_stories"];
        [_tableView reloadData];
        
        // 该定时器用于首页图片定时展示
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(dealWithTimer)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        
        if ([_refreshControl isRefreshing]) {
            [_refreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)dealWithTimer {
    CGPoint offset = _scrollView.contentOffset;
    NSInteger page = offset.x / ScreenWidth;
    if (page == _topDataList.count - 1) {
        page = 0;
    }
    else{
        page++;
    }
    
    [_scrollView setContentOffset:CGPointMake(page * ScreenWidth, 0) animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  80;
}

- (UIView *)tableView:(UITableView *)tablewView viewForHeaderInSection:(NSInteger)section {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth , 200)];
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(5 * ScreenWidth, 200);
        for (int i = 0; i < 5; i++) {
            CustomImageView *imgView = [[CustomImageView alloc]initWithFrame:CGRectMake(i * ScreenWidth, 0, ScreenWidth, 200)];
            imgView.delegate = self;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.backgroundColor = [UIColor orangeColor];
            imgView.title = [NSString stringWithFormat:@"第%d张",i];
            imgView.tag = 100 + i;
            [_scrollView addSubview:imgView];
        }
        
    }
    
    for (int i = 0; i < _topDataList.count; i++) {
        CustomImageView *imgView = _scrollView.subviews[i];
        // 图片
        [imgView sd_setImageWithURL:[NSURL URLWithString:_topDataList[i][@"image"]]];
        // 标题
        imgView.title = _topDataList[i][@"title"];
    }
    return _scrollView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[NewsCell alloc]initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:ID];
    }
    
    
    cell.newsLabel.text = _dataList[indexPath.row][@"title"];
    // sizeToFit方法要在给label的text赋值之后使用
    [cell.newsLabel sizeToFit];
    
    NSString *urlString = _dataList[indexPath.row][@"images"][0];
    NSURL *url = [NSURL URLWithString:urlString];
    [cell.newsImageView sd_setImageWithURL:url];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.newsId = _dataList[indexPath.row][@"id"];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - CustomImageViewDelegate

- (void)customImageView:(CustomImageView *)customImgView didClickButton:(UIButton *)button {
    // 获取点击的图片的下标
    NSInteger index = customImgView.tag - 100;
    
    // 根据下标取_topDataList数组取出对应新闻的id
    NSString *ID = [NSString stringWithFormat:@"%@",_topDataList[index][@"id"]] ;
    
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.newsId = ID;
    [self.navigationController pushViewController:detail animated:YES];
}

// 根据文字和固定宽度获取动态高度
- (CGFloat)heightWithText:(NSString *)text {
    CGRect rect =
    [text boundingRectWithSize:CGSizeMake(200, MAXFLOAT)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                       context:nil];
    return rect.size.height;
}

- (void)refresh {
    [self getDataList];
}

@end
