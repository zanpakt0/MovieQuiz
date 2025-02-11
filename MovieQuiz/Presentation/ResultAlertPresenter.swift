import UIKit

struct ResultAlertPresenter {
    var model: AlertModel
    weak var viewController: UIViewController?
    weak var delegate: ResultAlertPresenterDelegate?
}

extension ResultAlertPresenter {
    func present() {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            delegate?.onButtonTapped()
        }
        alert.addAction(action)

        viewController.present(alert, animated: true, completion: nil)
    }
}
