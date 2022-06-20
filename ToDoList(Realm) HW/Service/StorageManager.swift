//
//  StorageManager.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 08.06.2022.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
   
    // MARK: - TaskList Methods
    func save(taskList: TaskList) {  // сохраняем лист
        write {
            realm.add(taskList)
        }
    }
    
    func delete(taskList: TaskList) { // удаляем лист и все вложенные в него задачи
        write {
            let tasks = taskList.tasks
            realm.delete(tasks) // удаляем задачи из списка и не засоряем базу
            realm.delete(taskList)
        }
    }
    
    func edit(taskList: TaskList, newValue: String) { // редактируем название листа
        write {
            taskList.name = newValue
        }
    }
    
    func done(taskList: TaskList) { // делем все задачи в листе выполненными
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Task Methods
    func save(task: Task, in taskList: TaskList) { // сохраняем задачу
        write {
            taskList.tasks.append(task)
        }
    }
        
    func delete(task: Task) { // удаляем задачу
        write {
            realm.delete(task)
        }
    }
    
    func edit(task: Task, newTask: String, newNote: String) { // редактируем задачу
        write {
            task.name = newTask
            task.note = newNote
        }
    }
    
    func done(task: Task) { // выполнение задачи
        write {
            task.isComplete.toggle() // меняем значнеие на противоположное (true/false)
        }
    }
    
    // MARK: - Private Method
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
}
