//
//  UITableView+DataChanged.m
//  JRFProject
//
//  Created by feng jia on 15-2-6.
//  Copyright (c) 2015年 company. All rights reserved.
//

#import "UITableView+DataChanged.h"
#import <objc/runtime.h>

@implementation UITableView (DataChanged)

static NSString *kIndexPath = @"kIndexPath";
static NSString *kChangeBlock = @"kChangeBlock";
static NSString *kDatasource = @"kDatasource";
static NSString *kPrimaryKey = @"kPrimaryKey";

- (void)addDataChangedObserver:(NSMutableArray *)datasource
                    primaryKey:(NSString *)primaryKey
                   changeBlock:(DataChangeBlock)changeBlock {
    
    //给类别关联属性
    objc_setAssociatedObject(self, (__bridge const void *)(kDatasource), datasource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(kPrimaryKey), primaryKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(kChangeBlock), changeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    //添加监听方法
    [self removeObserver];
    [self addObserver];
    
}

- (void)removeDataChangedObserver {
    [self removeObserver];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, (__bridge const void *)(kIndexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 获取属性和值

//根据传入的属性key值获取该属性
- (id)getPropertyKey:(id)key {
    id obj = objc_getAssociatedObject(self, (__bridge const void*)key);
    return obj;
}

//根据传入的属性名称和对象获取该对象对应属性的value
- (id)getObjPropertyValueByKey:(NSString *)key obj:(id)obj {
    unsigned int outCount, i;
    id propertyValue;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        if ([propertyName isEqualToString:key]) {
            propertyValue = [obj valueForKey:(NSString *)propertyName];
            break;
        }
    }
    free(properties);
    return propertyValue;
}

#pragma mark - Observer Operation

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(add:) name:TableViewOperationAddNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delete:) name:TableViewOperationDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:TableViewOperationUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:TableViewOperationRefreshNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TableViewOperationAddNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TableViewOperationDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TableViewOperationUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TableViewOperationRefreshNotification object:nil];
    
}

#pragma mark - Actions

- (void)add:(NSNotification *)notification {
    NSLog(@"调用了tableview的add消息事件");
    id obj = notification.object;
    //获取数据源数据进行对象添加
    NSMutableArray *datasource = [self getPropertyKey:kDatasource];
    if (datasource && obj) {
        if (datasource.count > 0) {
            if ([obj isKindOfClass:[datasource[0] class]]) {
                [datasource insertObject:obj atIndex:0];
                [self reloadData];
            }
        }
    }
    
    [self callback:TableViewOperationAdd obj:obj];
}

- (void)delete:(NSNotification *)notification {
    NSLog(@"调用了tableview的delete消息事件");
    id objNotify = notification.object;
    
    //从数据源中删除一个对象并刷新tableview
    [self changeDataSourceWithObj:objNotify operationType:TableViewOperationDelete];
    [self callback:TableViewOperationDelete obj:objNotify];
}

- (void)update:(NSNotification *)notification {
    NSLog(@"调用了tableview的update消息事件");
    id objNotify = notification.object;
    
    //从数据源更新一个对象并刷新tableview
    [self changeDataSourceWithObj:objNotify operationType:TableViewOperationUpdate];
    [self callback:TableViewOperationUpdate obj:objNotify];
}

- (void)refresh:(NSNotification *)notification {
    NSLog(@"调用了tableview的refresh消息事件");
    id obj = notification.object;
    
    //刷新tableview
    [self reloadData];
    [self callback:TableViewOperationRefresh obj:obj];
}

- (void)callback:(TableViewOperationType)operationType obj:(id)obj {

    DataChangeBlock block = objc_getAssociatedObject(self, (__bridge const void*)kChangeBlock);
    NSIndexPath *indexPath = objc_getAssociatedObject(self, (__bridge const void*)kIndexPath);
    if (block) {
        block(operationType, indexPath, obj);
    }
}

- (void)changeDataSourceWithObj:(id)objNotify operationType:(TableViewOperationType)operationType {
    
    //取出数据源
    NSMutableArray *datasource = [self getPropertyKey:kDatasource];
    
    //取出对象主键字段名
    NSString *primaryKey = [self getPropertyKey:kPrimaryKey];
    
    //取出对象主键字段对应的value值
    NSString *valueNotify = [self getObjPropertyValueByKey:primaryKey obj:objNotify];
    if (objNotify) {
        [datasource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *value = [self getObjPropertyValueByKey:primaryKey obj:obj];
            if ([valueNotify isEqualToString:value]) {
                if (operationType == TableViewOperationDelete) {
                    [datasource removeObject:objNotify];
                    NSLog(@"对象删除成功，刷新数据");
                } else if (operationType == TableViewOperationUpdate) {
                    [datasource replaceObjectAtIndex:idx withObject:objNotify];
                    NSLog(@"对象更新成功，刷新数据");
                }
                [self reloadData];
                *stop = YES;
            }
        }];
    }
}

@end
