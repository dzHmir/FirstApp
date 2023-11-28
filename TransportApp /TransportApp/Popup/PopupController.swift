//
//  PopupController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.11.23.
//

import UIKit
import SnapKit

typealias VoidBlock = () -> Void

class PopupController: UIViewController {
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Заголовок"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Подзаголовок"
        label.textAlignment = .center
        label.numberOfLines = 5
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(close),
            for: .touchUpInside
        )
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(accept),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var buttonContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var acceptAction: VoidBlock?
    
    init(style: Style, acceptAction: VoidBlock? = nil) {
        super.init(nibName: nil, bundle: nil)
        makeStyle(style)
        self.acceptAction = acceptAction
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeLayout()
        makeConstraints()
        makeGestures()
    }
    
    private func makeLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.addSubview(mainView)
        mainView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subTitleLabel)
        contentStack.addArrangedSubview(buttonContainer)
        
        buttonContainer.addArrangedSubview(acceptButton)
        buttonContainer.addArrangedSubview(cancelButton)
    }
    
    private func makeConstraints() {
        mainView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
        
        buttonContainer.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
    }
    
    private func makeGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.view.addGestureRecognizer(tap)
    }
    
    private func makeStyle(_ style: Style) {
        makeColorsFor(style)
        makeTextFor(style)
        makeLayoutFor(style)
    }
    
    private func makeColorsFor(_ style: Style) {
        switch style {
            case .confirm:
                self.acceptButton.backgroundColor = .systemRed.withAlphaComponent(0.8)
                
            case .info:
                self.cancelButton.backgroundColor = .systemGreen
                self.cancelButton.tintColor = .white
                
            case .custom(_, _, let acceptColor, let cancelColor, _):
                self.cancelButton.backgroundColor = cancelColor
                self.acceptButton.backgroundColor = acceptColor
        }
    }
    
    private func makeTextFor(_ style: Style) {
        switch style {
            case .confirm(let title, let subtitle):
                self.acceptButton.setTitle("Bestätigen", for: .normal)
                self.cancelButton.setTitle("Ablehnen", for: .normal)
                self.titleLabel.text = title
                self.subTitleLabel.text = subtitle

            case .info(title: let title, subtitle: let subtitle):
                self.cancelButton.setTitle("Закрыть", for: .normal)
                self.titleLabel.text = title
                self.subTitleLabel.text = subtitle
            case .custom(let title,  let subtitle, _, _, _):
                self.titleLabel.text = title
                self.subTitleLabel.text = subtitle
                self.acceptButton.setTitle("Подтвердить", for: .normal)
                self.cancelButton.setTitle("Отмена", for: .normal)
        }
    }
    
    private func makeLayoutFor(_ style: Style) {
        switch style {
            case .confirm:
                break
            case .info:
                self.acceptButton.isHidden = true
            case .custom(_, _, _, _, let isAcceptAvalible):
                self.acceptButton.isHidden = !isAcceptAvalible
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func accept() {
        self.dismiss(animated: true)
        self.acceptAction?()
    }
}

extension PopupController {
    enum Style {
        case confirm(title: String, subtitle: String? = nil)
        case info(title: String, subtitle: String? = nil)
        case custom(title: String, subtitle: String? = nil, acceptColor: UIColor = .systemGreen, cancelColor: UIColor = .white, isAcceptAvalible: Bool = true)
    }
}

extension PopupController {
    static func show(style: Style, acceptAction: VoidBlock? = nil) {
        let popup = PopupController(style: style, acceptAction: acceptAction)
        
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(popup, animated: true)
        }
    }
}
