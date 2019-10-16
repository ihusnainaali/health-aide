//
//  ExerciseDetailViewController.swift
//  WorkoutDiary
//
//  Created by Martin Rist on 15/10/2019.
//  Copyright © 2019 Martin Rist. All rights reserved.
//

import UIKit

protocol ExerciseDetailViewControllerDelegate: class {
  func exerciseDetailViewControllerDidCancel(_ controller: ExerciseDetailViewController)
  func exerciseDetailViewController(_ controller: ExerciseDetailViewController,
                                    didFinishAdding exercise: Exercise)
  func exerciseDetailViewController(_ controller: ExerciseDetailViewController,
                                    didFinishEditing exercise: Exercise)
}

class ExerciseDetailViewController: UITableViewController {

  // MARK: - Properties

  weak var delegate: ExerciseDetailViewControllerDelegate?
  var exerciseToEdit: Exercise?

  var showingDescriptionPlaceholder = true
  var descriptionViewContents: String {
    set {
      showingDescriptionPlaceholder = newValue.isEmpty
      if newValue.isEmpty {
        descriptionTextView.text = "Exercise description..."
        let startPosition = descriptionTextView.beginningOfDocument
        descriptionTextView.selectedTextRange = descriptionTextView.textRange(from: startPosition, to: startPosition)
        descriptionTextView.textColor = .placeholderText
      } else {
        descriptionTextView.text = newValue
        descriptionTextView.textColor = .label
      }
    }
    get {
      showingDescriptionPlaceholder ? "" : descriptionTextView.text
    }
  }

  // MARK: - Outlets

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    if let exercise = exerciseToEdit {

      // Set up view state for editing
      title = "Edit exercise"
      doneBarButton.isEnabled = true

      // Copy model data into view
      nameTextField.text = exercise.name
      descriptionViewContents = exercise.description

    } else {

      // Set up view state for adding
      title = "Add exercise"
      descriptionViewContents = ""
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    nameTextField.becomeFirstResponder()
  }

  // MARK: - Actions

  @IBAction func cancel(_ sender: Any) {
    delegate?.exerciseDetailViewControllerDidCancel(self)
  }

  @IBAction func done(_ sender: Any) {

    if let exercise = exerciseToEdit {

      // Copy view state back into model
      exercise.name = nameTextField.text!
      exercise.description = descriptionViewContents

      // Notify delegate of editing completion
      delegate?.exerciseDetailViewController(self,
                                             didFinishEditing: exercise)

    } else {

      // Create new exercise
      let exercise = Exercise(name: nameTextField.text!,
                              description: descriptionViewContents)
      delegate?.exerciseDetailViewController(self,
                                             didFinishAdding: exercise)
    }
  }
}

// MARK: - UITableViewDelegate

extension ExerciseDetailViewController {

  override func tableView(_ tableView: UITableView,
                          willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    // Prevents the rows behind the text fields being selected
    return nil
  }
}

// MARK: - UITextFieldDelegate

extension ExerciseDetailViewController: UITextFieldDelegate {

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {

    // Work out what the 'new' text would be
    let oldText = textField.text!
    let stringRange = Range(range, in: oldText)!
    let newText = oldText.replacingCharacters(in: stringRange, with: string)

    // Disable the 'done' button if the new text is empty
    doneBarButton.isEnabled = !newText.isEmpty

    return true
  }
}

// MARK: - UITextViewDelegate

extension ExerciseDetailViewController: UITextViewDelegate {

  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {

    // Work out what the 'new' text would be
    let oldText = textView.text!
    let stringRange = Range(range, in: oldText)!
    let newText = showingDescriptionPlaceholder
      ? text
      : oldText.replacingCharacters(in: stringRange, with: text)

    descriptionViewContents = newText
    return false
  }


  func textViewDidChangeSelection(_ textView: UITextView) {
   let startPosition = descriptionTextView.beginningOfDocument
    descriptionTextView.selectedTextRange = descriptionTextView.textRange(from: startPosition, to: startPosition)
  }
//  func textViewDidChangeSelection(_ textView: UITextView) {
//    if showingDescriptionPlaceholder {
//      let startPosition = descriptionTextView.beginningOfDocument
//      descriptionTextView.selectedTextRange = descriptionTextView.textRange(from: startPosition, to: startPosition)
//    }
//  }

}
