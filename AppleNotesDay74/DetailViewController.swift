//
//  DetailViewController.swift
//  AppleNotesDay74
//
//  Created by Samat on 17.08.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit

protocol NoteChanges {
    func edit(editedNote: String, at index: Int)
    func delete(at index: Int)
}

class DetailViewController: UIViewController {

    @IBOutlet var note: UITextView!
    
    var noteText: String?
    var delegate: NoteChanges?
    var noteIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboard()
        configureToolBar()
        configureTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let index = noteIndex else { return }
        delegate?.edit(editedNote: note.text, at: index)
    }
    
    
    func configureTextView() {
        note.text = noteText
    }
    
    func configureKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    func configureToolBar() {
        let spacer  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let trashSymbol = UIImage(systemName: "trash")
        let deleteButton = UIBarButtonItem(image: trashSymbol, style: .plain, target: self, action: #selector(deleteNote))
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        
        toolbarItems = [deleteButton, spacer, actionButton]
    }
    
    
    @objc func deleteNote() {
        let ac = UIAlertController(title: "Delete Note?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .default))
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            guard let index = self?.noteIndex else { return }
            self?.delegate?.delete(at: index)
            self?.noteText = nil
            self?.delegate = nil
            self?.noteIndex = nil
            self?.navigationController?.popViewController(animated: true)
        }))
        present(ac, animated: true)
    }
    
    
    @objc func shareNote() {
        guard note.text.count > 0 else { return }
        guard let shareText = note.text else { return }
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItems?[0]
        present(vc, animated: true)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
           guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
           
           let keyboardScreenEndFrame = keyboardValue.cgRectValue
           let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
           
           if notification.name == UIResponder.keyboardWillHideNotification {
               note.contentInset = .zero
           } else {
               note.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
           }
           
           note.scrollIndicatorInsets = note.contentInset
           
           let selectedRange = note.selectedRange
           note.scrollRangeToVisible(selectedRange)
       }
    
}
