//
//  UITableView+DataChanged.h
//  JRFProject
//
//  Created by feng jia on 15-2-6.
//  Copyright (c) 2015年 company. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  定义tableview操作类型
 */
typedef NS_ENUM(NSInteger, TableViewOperationType) {
    TableViewOperationAdd = 0,
    TableViewOperationDelete,
    TableViewOperationUpdate,
    TableViewOperationRefresh
};

/*
 *  定义tableview操作消息通知，用于想要改变tableview显示的数据时调用
 */
#define TableViewOperationAddNotification  @"TableViewOperationAddNotification"
#define TableViewOperationDeleteNotification @"TableViewOperationDeleteNotification"
#define TableViewOperationUpdateNotification @"TableViewOperationUpdateNotification"
#define TableViewOperationRefreshNotification @"TableViewOperationRefreshNotification"

// block回调，返回操作类型、操作indexpath、以及变更对象
typedef void(^DataChangeBlock)(TableViewOperationType operationType, NSIndexPath *indexPath, id obj);

/*
 *  增加tableview数据改变观察者，当数据源中数据改变时可通过postNotification方法
 *  发送通知消息（需要使用者自己调用），该类别会根据消息类型来对数据源进行增删改更新等
 *  相关操作，并更新tableview. 
 *  使用方法：
 *  1. 进入页面时调用  addDataChangedObserver  方法增加监听
 *  2. 离开页面时调用  removeDataChangedObserver 方法删除监听
 */
@interface UITableView (DataChanged)

/*
 *  使用时直接调用该方法即可，添加tableview监听
 *  datasource: tableview显示时的数据源
 *  primaryKey: datasource中对象的主键字段名（例如 Person对象中的 personid）
 *  用于更新对象和删除对象时使用
 *  changeBlock: 回调返回操作类型、操作indexpath、以及变更对象
 */
- (void)addDataChangedObserver:(NSMutableArray *)datasource
                    primaryKey:(NSString *)primaryKey
                   changeBlock:(DataChangeBlock)changeBlock;

/*
 *  删除table监听，和方法 addDataChangedObserver 对应使用
 */
- (void)removeDataChangedObserver;


/*
 *  点击一个cell进入下一个页面或者选中某一个cell进行操作时可调用此方法
 */
- (void)selectIndexPath:(NSIndexPath *)indexPath;
@end
