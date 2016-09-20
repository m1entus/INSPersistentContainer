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
    var fetchedResultsController: NSFetchedResultsController<Entity>!

    var persistentContainer: INSPersistentContainer {
        return ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer)!
    }
    
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<Entity>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "isEven = %@", argumentArray: [true])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        _ = try? fetchedResultsController.performFetch()
        collectionView.dataSource = self
        collectionView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func addInBackgroundButtonTapped(_ sender: AnyObject) {
        
        persistentContainer.performBackgroundTask { context in
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context) as! Entity
            obj.name = "test"
            obj.isEven = false
            _ = try? context.save()
            
            self.persistentContainer.performBackgroundTask { context in
                let obj = context.object(with: obj.objectID) as! Entity
                obj.name = "test1"
                obj.isEven = true
                _ = try? context.save()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }

}

