//
//  DetailTaskListViewController.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 07.06.2022.
//

import UIKit
import RealmSwift

protocol NewTasktViewControllerDelegate {
    func updateUI()
}

class DetailTaskListViewController: UITableViewController {
    
    var taskList: TaskList!
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
                
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Tasks" : "Completed Tasks"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListDetailCell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Deletle") { (_, _,_) in
            StorageManager.shared.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let done = indexPath.section == 0 ? "Done" : "Un done"
        
        let doneAction = UIContextualAction(style: .normal, title: done) { (_, _, isDone) in
            StorageManager.shared.done(task: task)
            
            let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)      // определяем индексы секций текущих задач
            let indexPathForComplitedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)      // определяем индексы секций выполненых задач

            let destanationIndexRow = indexPath.section == 0 ? indexPathForComplitedTask : indexPathForCurrentTask  // опредеяем пункт назанчения задачи (куда перемещаем)
            
            tableView.moveRow(at: indexPath, to: destanationIndexRow)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, doneAction])
    }
    
    @objc private func addButtonPressed() {
//        showNewVC()
        showAlert()
    }
}

extension DetailTaskListViewController {
    private func showNewVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let newTaskVC = storyboard.instantiateViewController(identifier: "taskVC") as? NewTaskViewController else { return }
        newTaskVC.taskList = taskList
        newTaskVC.delegate = self
        present(newTaskVC, animated: true)
    }
}

extension DetailTaskListViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = AlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
        
        alert.action(with: task) { newTask, newNote in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, newTask: newTask, newNote: newNote)
                completion()
            } else {
                let task = Task()
                task.name = newTask
                task.note = newNote
                
                StorageManager.shared.save(task: task, in: self.taskList)
                let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        present(alert, animated: true)
    }
}

extension DetailTaskListViewController: NewTasktViewControllerDelegate  {
    func updateUI() {
        DispatchQueue.main.async {
            let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
            self.tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
