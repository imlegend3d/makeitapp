//
//  LogInViewController.swift
//  makeitapp
//
//  Created by David on 2019-05-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FBSDKLoginKit
import FacebookLogin
import FacebookCore


class LogInViewController: UIViewController, LoginButtonDelegate {

    private let appTitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Make It App"
        label.textAlignment = .center
        label.font = UIFont(name: "Marker felt", size: 34.0)
        return label
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    private let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = FlatSkyBlueDark()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Marker felt", size: 16)
        
        button.addTarget(self, action: #selector(handleLoginResister), for: .touchUpInside)
        
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nameSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let emailSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return view
    }()
    
    private let passWordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password..."
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let profileView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "file")
        //imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var logingRegisterSegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Login", "Register"])
        segmentControl.tintColor = UIColor.white
        segmentControl.selectedSegmentIndex = 1
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return segmentControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FlatSkyBlue()
        view.addSubview(appTitle)
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileView)
        view.addSubview(logingRegisterSegmentedControl)
        view.addSubview(facebookLoginButton)
        facebookLoginButton.delegate = self
        
        
        setUpInputContainerView()
        setUpLoginRegisterButton()
        setupProfileImageView()
        setupTittle()
        setUpSegmentControlView()
        setupFacebookButton()
    
    }
    override func viewWillAppear(_ animated: Bool) {
       // navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //MARK: - Handler methods
    
    @objc private func handleLoginResister(){
        if logingRegisterSegmentedControl.selectedSegmentIndex == 0{
            login()
        } else {
            register()
        }
    }
    
    private func login(){
        guard let email = emailTextField.text, let password = passWordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error as Any)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func register(){
        
        guard let email = emailTextField.text, let password = passWordTextField.text, let name = nameTextField.text  else {
            print("Not a valid email or password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {  [weak self] user, error in
            if error != nil {
                print(error!)
                return
            }
            guard let strongSelf = self else { return }
            
            //User authenticated
            let values = ["name" : name, "email" : email]
            
            var ref: DatabaseReference!
            
            guard let uid = user?.user.uid else { return }
            
            ref = Database.database().reference(fromURL: "https://makeitapp-b9187.firebaseio.com/")
            let userReference = ref.child("users").child(uid)
            userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil{
                    print(error as Any)
                    return
                }
                print("Saved user into Firebase database")
                strongSelf.showViewController()
                
            })
        }
       
    }
    
    private func showViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Facebook Login methods
    private func checkForFaceBookLoginStatus() {
        
        if let accessToken = AccessToken.current {
            print("User already logged in with Facebook token")
            print(accessToken)
             // Send to other VC
            showViewController()
            
        } else {
            
            let FBManager = LoginManager()
            FBManager.logIn(permissions: [Permission.publicProfile, Permission.userPhotos], viewController: self) { (loginResults) in
                switch loginResults {
                case .failed(let err):
                    print(err)
                case .cancelled:
                    print("Cancelled login")
                case.success(granted: _, declined: _, token: _):
                    print("Logged in")
                    
                    // Send to other VC
                    self.showViewController()
                }
                
            }
            
        }
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("user facebook logged in")
        checkForFaceBookLoginStatus()

    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        if AccessToken.current == nil {
           print("User Facebook logged out")
        }
    }

    
    //MARK: - UI set up methods
    
    @objc private func handleLoginRegisterChange(){
        let title = logingRegisterSegmentedControl.titleForSegment(at: logingRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of containerview
        inputContainerViewHeightAnchor?.constant = logingRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: logingRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //change height of email field
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo:inputContainerView.heightAnchor , multiplier: logingRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height of password field
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passWordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: logingRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    private func setupFacebookButton(){
        facebookLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookLoginButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 50).isActive = true
        facebookLoginButton.widthAnchor.constraint(equalTo: loginRegisterButton.widthAnchor).isActive = true
        //facebookLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupTittle(){
        appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appTitle.bottomAnchor.constraint(equalTo: profileView.topAnchor, constant: -12).isActive = true
        appTitle.widthAnchor.constraint(equalToConstant: 175).isActive = true
        appTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupProfileImageView() {
        profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileView.bottomAnchor.constraint(equalTo: logingRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    private func setUpSegmentControlView(){
        logingRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logingRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        logingRegisterSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        logingRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    private func setUpInputContainerView() {
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
       
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        
        inputContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparator)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparator)
        inputContainerView.addSubview(passWordTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeparator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparator.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeparator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passWordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passWordTextField.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor).isActive = true
        passWordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        passwordTextFieldHeightAnchor = passWordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        
    }
    
    private func setUpLoginRegisterButton() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
}
