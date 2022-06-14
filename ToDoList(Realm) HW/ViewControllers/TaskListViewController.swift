//
//  TaskListViewController.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 07.06.2022.
//

import UIKit
import RealmSwift
import SwiftUI

protocol NewTaskListViewControllerDelegate {
    func updateUI()
}

class TaskListViewController: UITableViewController {
    
    private var taskLists: Results<TaskList>! // динамическая коллекция и при добавлении данные в реальном времени будет отображаться в интерфейсе
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
//        showNewVC()
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
        ? taskLists.sorted(byKeyPath: "name")
        : taskLists.sorted(byKeyPath: "date")
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.textLabel?.text = taskList.name
//        cell.detailTextLabel?.text = "\(taskList.tasks.filter("isComplete = false").count)"  - рабочее решение без расширения ячейки
        cell.congigure(with: taskList)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(identifier: "detailVC") as? DetailTaskListViewController else { return }
        navigationController?.pushViewController(detailVC, animated: true)
        detailVC.taskList = taskLists[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Deletle") { (_, _,_) in
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in // isDone - для определения окончания действия над стройкой (вернуть в исходное положение)
            self.showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true) // тут заканчиваем редактирование
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            StorageManager.shared.done(taskList: taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, doneAction])
    }
}
// MARK: - Extensios
extension TaskListViewController {
    private func showNewVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let newListVC = storyboard.instantiateViewController(identifier: "listVC") as? NewListViewController else { return }
        newListVC.delegate = self
        present(newListVC, animated: true)
    }
}

extension TaskListViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) { // = nil для того, что бы не пределывать методы вызова, которые были ранее. если nil, то добавление. если передаем значения, то редактирование.
        
        let title = taskList != nil ? "Edit List" : "New List"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.action(with: taskList) { newTaskList in
            
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newTaskList)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newTaskList
                
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        present(alert, animated: true)
    }
}

extension TaskListViewController: NewTaskListViewControllerDelegate {
    func updateUI() {
        DispatchQueue.main.async {
            let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
            self.tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}



/*  вносим через код занчения по умолчанию для стара. 1 раз загрузить и можно удалять (можно делать в Realm Studio)
 override func viewDidLoad() {
     super.viewDidLoad()
 let shoppingList = TaskList()
 shoppingList.name = "Shopping List"
 
 let moviesList = TaskList(value: ["Movies List", Date(), [["Forrest Gump"], ["Pulp Fiction", "", Date(), true]]]) // так делать не надо
 let milk = Task()
 milk.name = "Milk"
 milk.note = "2L"
 
 let bread = Task(value: ["Bread", "", Date(), true]) // данные заполняются в соответсии с расположением в модели
 let apples = Task(value: ["name": "Apples", "isComplete": true]) // данные заполняются по ключу модели
 
 shoppingList.tasks.append(milk)
 shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
 
 //StorageManager.shared.save(taskList: [shoppingList, moviesList]) - ЗАПИСЬ в базу будет происходить в текущем потоке "main", и это действие останавливает очередь (в этом варианте данные маленькие, сохранится быстро) но по факту тормозим компилятор и не выйдем из метода viewDidLoad() пока не произойдет сохранение. Следовательно делаем это ассинхронно.
 // При этом ЧТЕНИЕ данных из БД не блокирует основной поток и можем обращаться к данным во время записи в любом потоке (работает в реальном времени, без блокировки основного потока) - можем получать доступ к объекту сразу же как он появится в базе, без обновления интерфейса.
 DispatchQueue.main.async {
 StorageManager.shared.save(taskList: [shoppingList, moviesList])
 }
 */
