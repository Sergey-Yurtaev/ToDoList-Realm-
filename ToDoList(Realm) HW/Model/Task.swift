//
//  Task.swift
//  ToDoList(Realm) HW
//
//  Created by Sergey Yurtaev on 07.06.2022.
//

import RealmSwift

class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let  tasks = List<Task>()
}

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}




