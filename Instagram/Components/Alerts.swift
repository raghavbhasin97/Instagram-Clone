import UIKit

enum AlertMessages: String {
    case registrationFailed = "User registration failed."
    case registrationSucceeded = "User account has been created."
    case loginFailed = "Provied credentials are invalid."
    case sendResetFailed = "No accounts found for this email address."
    case sendResetSuccess = "Reset link successfully sent."
    case postShareFailed = "Error occured whle sharing your post."
}


func createErrorAlert(message: AlertMessages) -> UIAlertController{
    let alert = UIAlertController(title: "Aw, Snap!", message: message.rawValue, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    return alert
}


func createSuccessAlert(message: AlertMessages) -> UIAlertController{
    let alert = UIAlertController(title: "Success!", message: message.rawValue, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    return alert
}
