import Foundation

func validEmail(email: String) -> Bool {
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,3}"
    return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
}

func validPassword(password: String) -> Bool {
    return password.count > 5
}

func validUsername(username: String) -> Bool {
    return username.count > 2 && username.count < 20
}
