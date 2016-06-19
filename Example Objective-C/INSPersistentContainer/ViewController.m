//
//  ViewController.m
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Entity.h"

@interface ViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ViewController

- (NSPersistentContainer *)persistentContainer {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistentContainer.viewContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}
- (IBAction)addInBackgroundButtonTapped:(id)sender {
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * context) {
        Entity *desc = (Entity *)[NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:context];
        desc.name = @"NEW";
        [context save:nil];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[0] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

@end
