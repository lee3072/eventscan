//
//  ListViewController.swift
//  EventScan
//
//  Created by 이승헌 on 07/04/2019.
//  Copyright © 2019 eventScan. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var events: [NSManagedObject] = []
    
    static var didSelect = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        CameraViewController.should_appear = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "EventInfo", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventInfo")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            print("loading data")
            
            //read data by each object
            events = result as! [NSManagedObject]

            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "event_name") as! String)
                print(data.value(forKey: "location") as! String)
                print(data.value(forKey: "date") as! Date)
                print(data.value(forKey: "time") as! Date)
                print(data.value(forKey: "alert") as! String)
                print(data.value(forKey: "details") as! String)
//                print(data.value(forKey: "identifier") as! String)
                print("----------------\n")
            }
            
        } catch {
            print("Failed")
        }
       

        
        for data in events {
           let event_name = data.value(forKey: "event_name") as! String
           let location = data.value(forKey: "location") as! String
           let date = data.value(forKey: "date") as! Date
           let time = data.value(forKey: "time") as! Date
           let alert = data.value(forKey: "alert") as! String
           let details = data.value(forKey: "details") as! String
  
            //lets change this to if detail view adds new event call this method
//            addEventToCalendar(title: event_name, description: details, startDate: date, endDate: date)
            //if detail view edits existing event, remove original event, call this method again
            
            //if list view deletes an existing event, remove it from calender
        }
        
        tableView.reloadData()
    }
    
    
    

    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell") as! ListViewCell
        
        let event = events[indexPath.row];
        
        cell.eventName.text = event.value(forKey: "event_name") as? String
        let date = event.value(forKey: "date") as! Date
        let time = event.value(forKey: "time") as! Date
//        let date_string = date.description.split(separator: " ")
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        let timeFormatterPrint = DateFormatter()
        timeFormatterPrint.dateFormat = "HH:mm"
        let combined = "\(dateFormatterPrint.string(from: date)) \(timeFormatterPrint.string(from: time))"
        cell.eventDate.text = combined
        
        if (indexPath.row % 6 == 0) {
//            cell.backgroundColor = UIColor.cyan
            cell.backgroundColor = UIColor( red: CGFloat(16/255.0), green: CGFloat(0/255.0), blue: CGFloat(1/255.0), alpha: CGFloat(1) )
            cell.eventName.textColor = UIColor.white
            cell.eventDate.textColor = UIColor.white
//                UIColor(displayP3Red: 244, green: 208, blue: 71, alpha: 0.8)
        }
        else if (indexPath.row % 6 == 1) {
            cell.backgroundColor = UIColor( red: CGFloat(255/255.0), green: CGFloat(197/255.0), blue: CGFloat(10/255.0), alpha: CGFloat(1) )
        }
        else if (indexPath.row % 6 == 2) {
            cell.backgroundColor = UIColor( red: CGFloat(255/255.0), green: CGFloat(237/255.0), blue: CGFloat(79/255.0), alpha: CGFloat(1) )
        }
        else if (indexPath.row % 6 == 3) {
            cell.backgroundColor = UIColor( red: CGFloat(255/255.0), green: CGFloat(237/255.0), blue: CGFloat(79/255.0), alpha: CGFloat(0.6) )
        }
        else if (indexPath.row % 6 == 4) {
            cell.backgroundColor = UIColor( red: CGFloat(136/255.0), green: CGFloat(136/255.0), blue: CGFloat(136/255.0), alpha: CGFloat(1) )
        }
        else {
            cell.backgroundColor = UIColor( red: CGFloat(240/255.0), green: CGFloat(240/255.0), blue: CGFloat(240/255.0), alpha: CGFloat(1) )
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ListViewController.didSelect = indexPath.row
        DetailViewController.fromList = true
        DetailViewController.fromParser = false
        DetailViewController.shouldSet = true
        tabBarController?.selectedIndex = 2
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "EventInfo", in: context)
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventInfo")
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try context.fetch(request)
                print("loading data")
                //read data by each object
                events = result as! [NSManagedObject]
                deleteEventFromCalendar(identifier: events[indexPath.row].value(forKey: "identifier") as! String)
                context.delete(events[indexPath.row])
            } catch {
                print("Failed")
            }
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
            do {
                let result = try context.fetch(request)
                print("loading data")
                //read data by each object
                events = result as! [NSManagedObject]
            } catch {
                print("Failed")
            }
            tableView.reloadData()
            
        }
    }
    
    
    func deleteEventFromCalendar(identifier: String,completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    if (eventStore.event(withIdentifier: identifier) == nil) {
                        completion?(false, nil)
                        return
                        
                    }
                    
                    let event: EKEvent = eventStore.event(withIdentifier: identifier)!
                    do {
                        try eventStore.remove(event, span: .thisEvent)
                    } catch let e as NSError {
                        completion?(false, e)
                        return
                    }
                    completion?(true, nil)
                } else {
                    completion?(false, error as NSError?)
                }
            })
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
