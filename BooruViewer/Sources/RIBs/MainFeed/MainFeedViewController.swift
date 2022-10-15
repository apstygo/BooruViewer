//
//  MainFeedViewController.swift
//  BooruViewer
//
//  Created by Artem Pstygo on 15.10.2022.
//

import ModernRIBs
import UIKit

protocol MainFeedPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class MainFeedViewController: UIViewController, MainFeedPresentable, MainFeedViewControllable {

    weak var listener: MainFeedPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
    }

}
