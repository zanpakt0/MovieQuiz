import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private var movieQuizPresenter: MovieQuizPresenter!
}

extension MovieQuizViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.layer.cornerRadius = 20
        previewImageView.layer.borderWidth = 8
        previewImageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        noButton.accessibilityIdentifier = "No"
        yesButton.accessibilityIdentifier = "Yes"
        showLoadingIndicator()
        removeAnswerCorrectnessIndication()
        activityIndicator.hidesWhenStopped = true

        movieQuizPresenter = MovieQuizPresenter(viewController: self)
    }
    func show(quiz step: QuizStepViewModel) {
        var image: UIImage? = nil
        if let data = step.imageData {
            image = UIImage(data: data)
        }
        counterLabel.text = step.questionNumber
        previewImageView.image = image
        questionLabel.text = step.question
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func indicateWrongAnswer() {
        previewImageView.layer.borderColor = UIColor(named: "YP Red")?.cgColor
    }
    func indicateCorrectAnswer() {
        previewImageView.layer.borderColor = UIColor(named: "YP Green")?.cgColor
    }
    func removeAnswerCorrectnessIndication() {
        previewImageView.layer.borderColor = UIColor.clear.cgColor
    }
}

private extension MovieQuizViewController {
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.set(answer: true)
    }
    @IBAction func noButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.set(answer: false)
    }
}
