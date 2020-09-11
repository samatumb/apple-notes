//
//  ViewController.swift
//  AppleNotesDay74
//
//  Created by Samat on 17.08.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, NoteChanges {

    var notes = [Note]() { didSet { configureToolBar() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureToolBar()
        
        let defaults = UserDefaults.standard
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes")
            }
        }
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.systemOrange
        navigationController?.toolbar.tintColor = UIColor.systemOrange
        navigationController?.setToolbarHidden(false, animated: false)
        
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setEditMode))
    }
    
    
    func configureToolBar() {
        let spacer  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let notesLabel = UIBarButtonItem(title: notes.count > 0 ? "\(notes.count) Notes" : "No Notes", style: .plain, target: self, action: nil)
        notesLabel.tintColor = .label
        
        let newNoteSymbol = UIImage(systemName: "square.and.pencil")
        let newNote = UIBarButtonItem(image: newNoteSymbol, style: .plain, target: self, action: #selector(addNewNote))
        
        toolbarItems = [spacer, notesLabel, spacer, newNote]
    }
    
    
    @objc func setEditMode() {
        tableView.isEditing.toggle()
    }

    
    @objc func addNewNote() {
        
        let newNote = Note(body: "")
        let lastIndex = notes.count
        notes.append(newNote)
        
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.noteText = newNote.body
            vc.noteIndex = lastIndex
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.subtitle
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.noteText = notes[indexPath.row].body
            vc.noteIndex = indexPath.row
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            save()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedNote = notes[sourceIndexPath.row]
        notes.remove(at: sourceIndexPath.row)
        notes.insert(movedNote, at: destinationIndexPath.row)
        save()
    }
    
    
    func delete(at index: Int) {
        notes.remove(at: index)
        tableView.reloadData()
        save()
    }
    
    
    func edit(editedNote: String, at index: Int) {
        notes[index] = Note(body: editedNote)
        tableView.reloadData()
        save()
    }
    
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes")
        }
    }
}

