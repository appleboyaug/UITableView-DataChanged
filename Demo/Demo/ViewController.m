//
//  ViewController.m
//  Demo
//
//  Created by feng jia on 15-3-6.
//  Copyright (c) 2015年 company. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+DataChanged.h"
#import "EditViewController.h"
#import "Person.h"
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSMutableArray *datasource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.datasource = [NSMutableArray array];
    for (int i= 0; i < 19; i++) {
        Person *p = [[Person alloc] init];
        p.pid = [NSString stringWithFormat:@"%d", i * 10];
        p.name = [NSString stringWithFormat:@"name%d", i * 10];
        [self.datasource addObject:p];
    }
    
    [self.tableview addDataChangedObserver:self.datasource primaryKey:@"pid" changeBlock:^(TableViewOperationType operationType, NSIndexPath *indexPath, id obj) {
        NSLog(@"%@", indexPath);
        NSLog(@"%ld", operationType);
        NSLog(@"%@", obj);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defcell"];
    Person *p = [self.datasource objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView selectIndexPath:indexPath];
    Person *p = [self.datasource objectAtIndex:indexPath.row];
    EditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"secondvc"];
    vc.p = p;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
