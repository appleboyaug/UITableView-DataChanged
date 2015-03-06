//
//  EditViewController.m
//  Demo
//
//  Created by feng jia on 15-3-6.
//  Copyright (c) 2015年 company. All rights reserved.
//

#import "EditViewController.h"
#import "UITableView+DataChanged.h"
@interface EditViewController ()

@property (nonatomic, strong) IBOutlet UITextField *tfOrg;
@property (nonatomic, strong) IBOutlet UITextField *tfNew;

- (IBAction)back:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)delete:(id)sender;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tfOrg.text = self.p.name;
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
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)delete:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:TableViewOperationDeleteNotification object:self.p];
}
- (IBAction)update:(id)sender {
    if (self.tfNew.text.length <= 0) {
        return;
    }
    self.p.name = [NSString stringWithFormat:@"%@", self.tfNew.text];
    [[NSNotificationCenter defaultCenter] postNotificationName:TableViewOperationUpdateNotification object:self.p];
}

@end
