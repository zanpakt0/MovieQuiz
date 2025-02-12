import UIKit

struct ResultAlertPresenter {
    var model: AlertModel
    weak var viewController: UIViewController?

    init(viewController: UIViewController, model: AlertModel) {
        self.viewController = viewController
        self.model = model
    }
}

extension ResultAlertPresenter {
    func present() {
        guard let viewController else {
            return
        }

        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.onButtonTap?()
        }
        alert.addAction(action)

        viewController.present(alert, animated: true, completion: nil)
    }
}
