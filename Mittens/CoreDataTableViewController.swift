//
//  CoreDataTableViewController.swift
//
//  Created by CS193p Instructor.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate
    
{

    // quando setto questa variabile pubblica , viene fatto l'update della tableview
    var fetchedResultsController: NSFetchedResultsController<Chat>? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    //sono io che devo essere notificato quando il fatch risulta diverso
                    frc.delegate = self
                    //esegue la request 
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections , sections.count > 0 {
           // print(sections[section].numberOfObjects)
            return sections[section].numberOfObjects
            
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections , sections.count > 0 {
            
            return sections[section].name
        } else {
            return nil
        }
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    //ogni volta che il database cambia il delegato richiama queste funzioni che servono per fare l'update della table view
    // MARK: NSFetchedResultsControllerDelegate
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController<Chat>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<Chat>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .insert: tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            case .delete: tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            default: break
        }
    }
    
    private func controller(controller: NSFetchedResultsController<Chat>, didChangeObject anObject: AnyObject, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController<Chat>) {
        tableView.endUpdates()
    }
    

}

