//
//  ViewController.swift
//  PopupKitExample
//
//  Created by Ryne Cheow on 13/1/17.
//  Copyright © 2017 Ryne Cheow. All rights reserved.
//

import UIKit
import PopupKit

enum Customiser: CustomStringConvertible {
    case horizontalLayout
    case verticalLayout
    case backgroundMask
    case showType
    case dismissType
    case dismissOnBackgroundTouch
    case dismissOnContentTouch
    case dismissAfterDelay

    var description: String {
        switch self {
        case .horizontalLayout:
            return "Horizontal layout"
        case .verticalLayout:
            return "Vertical layout"
        case .backgroundMask:
            return "Background mask"
        case .showType:
            return "Show type"
        case .dismissType:
            return "Dismiss type"
        case .dismissOnBackgroundTouch:
            return "Dismiss on background touch"
        case .dismissOnContentTouch:
            return "Dismiss on content touch"
        case .dismissAfterDelay:
            return "Dismiss after delay"
        }
    }
}

struct PopupTestViewModel {
    var customisers:[Customiser] = [
        .horizontalLayout,
        .verticalLayout,
        .backgroundMask,
        .showType,
        .dismissType,
        .dismissOnBackgroundTouch,
        .dismissOnContentTouch,
        .dismissAfterDelay
    ]
}


class TestViewController: UITableViewController {

    let viewModel = PopupTestViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PopupView Swift Example"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.customisers.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = viewModel.customisers[indexPath.row].description

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
