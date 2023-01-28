//
//  ViewController.swift
//  FirebaseToDo
//
//  Created by dzmitry on 27.01.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func signInAction() {
        // проверка полей логин и пароль
        guard let email = emailTF.text,
              let password = passwordTF.text,
              email != "",
              password != "" else {
            // показать Error
            displayErrorLabel(withText: "Info is incorrect")
            return
        }
        
        // регистрация
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error {
                self?.displayErrorLabel(withText: "Error occured: \(error.localizedDescription)")
            } else if let _ = user {
                // если замыкание отрабатывает без ошибок, перейти на новый экран
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
    }
    
    @IBAction func signUpAction() {
        // проверяем все поля
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            displayErrorLabel(withText: "Info is incorrect")
            return
        }
        
        // createUser
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                self?.displayErrorLabel(withText: "Registration was incorrect\n\(error.localizedDescription)")
            } else {
                guard let user = user else {
                    return
                }
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
        }
    }
    
    // анимация появления Error
    private func displayErrorLabel(withText text: String) {
       errorLabel.text = text
       UIView.animate(withDuration: 5,
                      delay: 0,
                      usingSpringWithDamping: 1,
                      initialSpringVelocity: 1,
                      options: .curveEaseInOut, // плавно появляется и плавно исчезает
                      animations: { [weak self] in
                          self?.errorLabel.alpha = 1
                      }) { [weak self] _ in
           self?.errorLabel.alpha = 0
       }
   }
}

