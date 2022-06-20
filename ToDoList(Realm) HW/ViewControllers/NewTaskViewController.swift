//
//  NewTaskViewController.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 12.06.2022.
//

import UIKit
import RealmSwift

class NewTaskViewController: UIViewController {

    private let newTask = Task()
    
    var taskList: TaskList!
    var delegate: NewTasktViewControllerDelegate!
    
    @IBOutlet weak var currentTaskListLabel: UILabel!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveEnabled()
        currentTaskListLabel.text = taskList.name
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveEndExit()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func saveEndExit() {
        guard let newTaskValue = taskTextField.text else { return }
        
        newTask.name = newTaskValue
        newTask.note = noteTextField.text ?? ""
        
        DispatchQueue.main.async {
            StorageManager.shared.save(task: self.newTask, in: self.taskList)
        }
        
        self.delegate.updateUI()
        dismiss(animated: true)
    }
    
    private func setupSaveEnabled() {
        taskTextField.addTarget(
            self,
            action: #selector(textFieldsDidChanged),
            for: .editingChanged
        )
    }
    
    @objc private func textFieldsDidChanged() {
        guard let newTaskListName = taskTextField.text else { return }
        saveButtonOutlet.isEnabled = !newTaskListName.isEmpty ?  true : false
    }
}
