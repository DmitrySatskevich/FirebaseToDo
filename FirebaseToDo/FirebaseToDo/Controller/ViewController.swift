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
    
    // отлавливает, пользователь залогирован или нет
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.delegate = self
        passwordTF.delegate = self
        ref = Database.database().reference(withPath: "users")

        // если пользователь уже есть, производим переход в личный кабинет
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let _ = user else {
                return
            }
            self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // чистим поля
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
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
    
//  Смещение экрана при появлении клавиатуры
    @objc func kbDidShow(notification: Notification) {
        self.view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= (keyboardSize.height / 2)
        }
    }
    
//  При закрытии клавиатура, экран возвращается в исходное положение
    @objc func kbDidHide() {
        self.view.frame.origin.y = 0
    }
}

extension LoginViewController: UITextFieldDelegate {
//    Скрываем клавиатуру, по нажатию "return".
//    Text Field нужно подключить "delegate"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Скрытие клавиатуры по тапу за пределами Text Field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true) // Скрывает клавиатуру, вызванную для любого объекта
    }
}
