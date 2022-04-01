//
//  ContentView.swift
//  ShadeInc
//
//  Created by Randi Gjoni on 3/29/22.
//
//BAOBAO
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
public var isError = false
class AppViewModel: ObservableObject {
    public let database = Database.database().reference()
    let auth = Auth.auth()
    @Published var signedIn = false
    var isSignedIn: Bool{
        return auth.currentUser != nil
    }
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    var isError = true
    public func sendVerficationEmail(){
        if self.authUser != nil && !self.authUser!.isEmailVerified {
               self.authUser!.sendEmailVerification(completion: { (error) in
                   // Notify the user that the mail has sent or couldn't because of an error.
                   
               })
           }
           else {
               // Either the user is not available, or the user is already verified.
           }
               
    }
    
    func signIn(email:String, password:String)
    {
        auth.signIn(withEmail: email, password: password){
            [weak self ]result,error in
            guard result != nil, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    func signUp(email:String, password:String, username: String)
    {
        let object:[String: Any] = [
            "email":email as NSObject,
        ]
        self.database.child(username).observeSingleEvent(of: .value, with:{ snapshot in
           let value = snapshot.value as? [String:Any]
            if(value == nil)
            {
                self.database.child(username).setValue(object)
                self.auth.createUser(withEmail: email, password: password)
                {
                    [weak self ] result,error in
                    guard result != nil, error == nil else {
                        return
                    }
                   
                    
                    DispatchQueue.main.async {
                        self?.signedIn = true
                    }
                    self?.sendVerficationEmail()
                }
            }
            else{
                self.isError = true
            }
            
        })
        
    }
    func signOut()
    {
        try? auth.signOut()
        self.signedIn = false
    }
}
struct ContentView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        NavigationView{
            if viewModel.signedIn{
                
                
                Button(action: {
                    viewModel.signOut()
                },
                       label:{
                    Text("Sign Out")
                        .frame(width:200,height:50)
                        .background(Color.green)
                        .foregroundColor(Color.blue)
                })
               
            }
            else{
                SignInView()
            }
        }
        .onAppear{
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}
struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        
        VStack{
            Image("johnscat").resizable()
                .scaledToFit()
                .frame(width: 150, height:150)
            VStack{
                TextField("Email Address",text: $email )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                SecureField("Password",text: $password )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else{
                        return
                    }
                    viewModel.signIn(email: email, password: password)
                }, label: {Text("Sign in")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                })
                NavigationLink("Create Account", destination: SignUpView())
                    .padding()
                    
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Sign In")
        
    }
}
struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    @State var username = ""
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        
        VStack{
            Image("johnscat").resizable()
                .scaledToFit()
                .frame(width: 150, height:150)
            VStack{
                TextField("Email Address",text: $email )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                TextField("Username",text: $username )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                SecureField("Password",text: $password )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else{
                        return
                    }
                    viewModel.signUp(email: email, password: password, username:username)
                }, label: {Text("Create Account")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                })
                .alert(isPresented: $viewModel.isError) {
                        Alert(
                            title: Text("Current Location Not Available"),
                            message: Text("Your current location can’t be " +
                                            "determined at this time.")
                        )
                    }
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Create Account")
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
