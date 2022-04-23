//
//  LoginViewController.swift
//  Messager
//
//  Created by lsaac on 2022/4/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController {
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView();
        scrollView.clipsToBounds = true
        return scrollView;
    }()
    
    private  let emailField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private  let passwordField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    
    private let loginButton:UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .link
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius  = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 20,weight:.bold)
        return btn
    }()
    
    let fbLoginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    let googleLoginButton : GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(gooleSignIn), for: .touchUpInside)
        return button
    }()
    
    private var loginObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login in"
        
        loginObserver =  NotificationCenter.default.addObserver(forName: Notification.Name.didLogInNotification, object: nil, queue: .main) { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtontapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        // Add subViews;
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLoginButton)
        
        // Do any additional setup after loading the view.
    }
    
    
    deinit {
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginButton)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom+10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+20, width: scrollView.width-60, height: 52)
        fbLoginButton.frame = CGRect(x: 30, y: loginButton.bottom+20, width: scrollView.width-60, height: 52)
        
    
        
        googleLoginButton.frame = CGRect(x: 30, y: fbLoginButton.bottom+20, width: scrollView.width-60, height: 52)
        
    }
    
    @objc private func loginButtontapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,let password = passwordField.text,!email.isEmpty,!password.isEmpty,password.count>=4 else{
            alertUserLoginError()
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let stongSelf = self else{
                return
            }
            
            
            guard let result = authResult,error == nil else{
                print("bad login")
                return
            }
            let user = result.user
            print("Loggin in user\(user)")
            stongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Acount"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func gooleSignIn(){
        let clientID = FirebaseApp.app()?.options.clientID
        guard let clientID = clientID else{
            return
        }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
       
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { [ weak self] user, error in
            
            guard let stongSelf = self else{
                return
            }
            
            
           guard error == nil else {
               print("goole login error \(error)")
               return
               
           }
            
            guard let user = user else { return }

            let emailAddress = user.profile?.email

            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName

            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            print("emailAddress:\(emailAddress)")
            print("fullName:\(fullName)")
            print("givenName:\(givenName)")
            print("familyName:\(familyName)")
            print("profilePicUrl:\(profilePicUrl)")
            
            
            user.authentication.do { authentication, error in
                    guard error == nil else { return }
                    guard let authentication = authentication else { return }

                    let idToken = authentication.idToken
                guard let idToken = idToken else {
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                    guard authResult != nil,error == nil else{
                        return
                    }
                    
                    print("goole login right!")
                    
                    //试试通知
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
//                    stongSelf.navigationController?.dismiss(animated: true, completion: nil)
                }
                print("idToken:\(idToken)")
                    // Send ID token to backend (example below).
                }
            
            guard let emailAddress = emailAddress,let firstName = givenName,let lastName = familyName else {
                return
            }
            
            Databasemanager.shared.userExists(with: emailAddress) { exists in
                if !exists {
                    // inset to database
                    Databasemanager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: emailAddress))
                }
            }
            
            
           
           // If sign in succeeded, display the app's main content View.
         }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension LoginViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtontapped()
        }
        
        return true
        
        
    }
}

extension LoginViewController:LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        
        
        guard let token = result?.token?.tokenString else{
            print("facebook登录失败");
            return
        }
        
        let FacebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: token, version: nil,httpMethod: .get)
        
        FacebookRequest.start { connection, result, error in
            guard let result = result as? [String:Any],error == nil else {
                print("failed to make facebook graph request")
                return
            }
            
            guard let userName = result["name"] as? String,let email = result[
                "email"] as? String else{
                    return
                }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else{
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            Databasemanager.shared.userExists(with: email) { exist in
                if !exist {
                    Databasemanager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authresult, error in
                
                guard let stongSelf = self else{
                    return
                }
                
                guard let result = authresult,error == nil else{
                    return
                }
                
                print("登录成功\(result)")
                stongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
        
    }
    
    
}
