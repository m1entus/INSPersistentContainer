//
//  ViewController.swift
//  INSPersistentContainer-Swift2
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController!

    var persistentContainer: INSPersistentContainer {
        return ((UIApplication.sharedApplication().delegate as? AppDelegate)?.persistentContainer)!
    }
    
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest(entityName: "Entity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        _ = try? fetchedResultsController.performFetch()
        collectionView.dataSource = self
        collectionView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func addInBackgroundButtonTapped(sender: AnyObject) {
        persistentContainer.performBackgroundTask { context in
            let obj = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: context) as! Entity
            obj.name = "test"
            _ = try? context.save()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }

}

