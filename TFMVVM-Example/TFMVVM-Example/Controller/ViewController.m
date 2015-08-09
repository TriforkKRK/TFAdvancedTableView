//
//  ViewController.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 01/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "ViewController.h"
#import "TFDynamicTableViewDataSource.h"
#import "TFViewModelResultsController.h"
#import "TFSectionViewModel.h"
#import "SimpleRowViewModel.h"
#import "SimpleCell.h"
#import "SimpleHeaderViewWithFolding.h"
#import "SimpleHeaderViewModel.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet TFDynamicTableViewDataSource *dynamicDataSource;
@property (strong, nonatomic) TFViewModelResultsController * viewModelController;
@end

@implementation ViewController

- (TFViewModelResultsController *)viewModelController
{
    if (_viewModelController == nil) {
        _viewModelController = [TFViewModelResultsController withMapping:@{(id)[SimpleRowViewModel class] : [SimpleCell class],
                                                                           (id)[SimpleHeaderViewModel class]: [SimpleHeaderViewWithFolding class]
                                                                           }];
        
        TFSectionViewModel * s1 = [[TFSectionViewModel alloc] init];
        s1.rows = @[[SimpleRowViewModel withColor:[UIColor redColor] name:@"c1"],
                    [SimpleRowViewModel withColor:[UIColor blueColor] name:@"c2 d hasjd gashj dgsa dvgha dsgha das d"],
                    [SimpleRowViewModel withColor:[UIColor grayColor] name:@"cc3  dasd sajd sa dhsah gdhjsa gdjhsa gdjhsa gdjsa gdjs gas dvhas vdhjsa gdhj"]];
        
        SimpleHeaderViewModel * h2 = [[SimpleHeaderViewModel alloc] initWithModel:nil];
        h2.title = @"header 2, click to fold";
        
        TFSectionViewModel * s2 = [[TFSectionViewModel alloc] init];
        s2.rows = @[[SimpleRowViewModel withColor:[UIColor greenColor] name:@"c21dbshajdg sah dgah gdhas gdhja gdhjsa gdsg dhsf agdhs afhgdfs  sgahjSG A DGSDGJA GDHJS aghd fsagh sfd a"],
                    [SimpleRowViewModel withColor:[UIColor yellowColor] name:@"c22 dsgadfdghsa fdgha"]];
        s2.header = h2;
        _viewModelController.sections = @[s1, s2];
    }
    
    return _viewModelController;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.dynamicDataSource.provider = self.viewModelController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
