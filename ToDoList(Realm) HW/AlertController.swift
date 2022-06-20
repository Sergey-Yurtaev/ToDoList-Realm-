//
//  AlertController.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 12.06.2022.
//

import UIKit

class AlertController: UIAlertController {
    
    var doneButton = "Save"
    
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
        
        if taskList != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard let newTaskList = self?.textFields?.first?.text else { return }
            guard !newTaskList.isEmpty else { return }
            completion(newTaskList)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        addAction(cancelAction)
        addAction(saveAction)
        addTextField { testField in
            testField.placeholder = "Enter task list name"
            testField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) {
        
        if task != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard let newTask = self?.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self?.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(cancelAction)
        addAction(saveAction)
        addTextField { taskTextField in
            taskTextField.placeholder = "Enter task name"
            taskTextField.text = task?.name
        }
        addTextField { noteTextfield in
            noteTextfield.placeholder = "Enter a note for the task"
            noteTextfield.text = task?.note
        }
    }
    
    deinit {
        print("AlertController has been dealocated")
    }
}

