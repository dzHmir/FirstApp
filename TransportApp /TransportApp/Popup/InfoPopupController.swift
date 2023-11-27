//
//  InfoPopupController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.11.23.
//

import UIKit
import SnapKit

class InfoPopupController: UIViewController {
    
    weak var timer: Timer?
    
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
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
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
    
    init(style: Style) {
        super.init(nibName: nil, bundle: nil)
        makeStyle(style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeLayout()
        makeConstraints()
        makeGestures()
        startTimer()
    }
    
    private func makeLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.addSubview(mainView)
        mainView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subTitleLabel)
    }
    
    private func makeConstraints() {
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-75)
        }
    }
    
    private func makeGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.view.addGestureRecognizer(tap)
    }
    
    private func makeStyle(_ style: Style) {
        makeTextFor(style)
        
    }
    
    private func makeTextFor(_ style: Style) {
        switch style {
        case .info(title: let title, subtitle: let subtitle):
            self.titleLabel.text = title
            self.subTitleLabel.text = subtitle
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.close), userInfo: nil, repeats: true)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func accept() {
        self.dismiss(animated: true)
       
    }
}

extension InfoPopupController {
    enum Style {
        case info(title: String, subtitle: String? = nil)
    }
}

extension InfoPopupController {
    static func show(style: Style) {
        let popup = InfoPopupController(style: style)
        
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
