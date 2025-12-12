//
//  Uitils.swift
//  real calender
//
//  Created by Mac on 05/12/25.
//

import SwiftUI

extension UIAlertAction {
    static var Cancel: UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
    
    static var OK: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}

var windowScene: UIWindowScene? {
    let allScenes = UIApplication.shared.connectedScenes
    return allScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
}
@MainActor
var rootController: UIViewController? {
    var root = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .first(where: { $0 is UIWindowScene }).flatMap({ $0 as? UIWindowScene })?.windows
        .first(where: { $0.isKeyWindow })?.rootViewController
    while root?.presentedViewController != nil {
        root = root?.presentedViewController
    }
    return root
}

func presentAlert(message: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil, tertiaryAction: UIAlertAction? = nil) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: "Real Calender", message: message, preferredStyle: .alert)
        alert.addAction(primaryAction)
        if let secondary = secondaryAction { alert.addAction(secondary) }
        if let tertiary = tertiaryAction { alert.addAction(tertiary) }
        rootController?.present(alert, animated: true, completion: nil)
    }
}
