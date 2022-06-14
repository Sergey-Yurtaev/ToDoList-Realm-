//
//  NewListViewController.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 10.06.2022.
//

import UIKit
import RealmSwift

class NewListViewController: UIViewController {

    var delegate: NewTaskListViewControllerDelegate!
    
    @IBOutlet weak var taskListTextField: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveEnabled()
    }
    
    @IBAction func save(_ sender: Any) {
        saveEndExit()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func saveEndExit() {
        let newTaskList = TaskList()
        guard let newTaskListName = taskListTextField.text else { return }
        newTaskList.name = newTaskListName
        
        DispatchQueue.main.async {
            StorageManager.shared.save(taskList: newTaskList)
        }
        
        delegate.updateUI()
        
        dismiss(animated: true)
    }
    
    private func setupSaveEnabled() {
        taskListTextField.addTarget(
            self,
            action: #selector(textFieldsDidChanged),
            for: .editingChanged
        )
    }
    
    @objc private func textFieldsDidChanged() {
        guard let newTaskListName = taskListTextField.text else { return }
        saveButtonOutlet.isEnabled = !newTaskListName.isEmpty ?  true : false
    }
}
