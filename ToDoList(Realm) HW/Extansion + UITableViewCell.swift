//
//  Extansion + UITableViewCell.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 15.06.2022.
//

import UIKit

extension UITableViewCell {
    func congigure(with taskList: TaskList) {
        let currentTask = taskList.tasks.filter("isComplete = false")
        let completedTaks = taskList.tasks.filter("isComplete = true")
        
        textLabel?.text = taskList.name
        
        if !currentTask.isEmpty {
            detailTextLabel?.text = "\(currentTask.count)"
            accessoryType = .none
        } else if !completedTaks.isEmpty {
            detailTextLabel?.text = nil
            accessoryType = .checkmark
        } else {
            detailTextLabel?.text = "0"
            accessoryType = .none
        }
    
    }
    
}
