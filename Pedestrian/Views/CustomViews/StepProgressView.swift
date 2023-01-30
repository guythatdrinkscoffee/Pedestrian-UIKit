//
//  StepsProgressView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import Combine
import SwiftUI
import EFCountingLabel

class StepProgressView: UIView {
    // MARK: - Public properties
    public var didReachMaxPublisher = CurrentValueSubject<Bool?,Never>(nil)
    
    // MARK: - Private properties
    private var maxValue: CGFloat = 10_000
    private var currentValue: CGFloat = 0
    private var startPoint: CGFloat = -((4 * Double.pi) / 2.88)
    private var didComplete = false
    private var endPoint: CGFloat {
        return -((5 * Double.pi) / 3.09)
    }
    
    // MARK: - UI
    private lazy var bottomTrackLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemTeal.withAlphaComponent(0.3).cgColor
        layer.lineCap = .round
        layer.strokeEnd = 1.0
        layer.lineWidth = 35
        return layer
    }()
    
    private lazy var progressTrackLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemTeal.cgColor
        layer.lineCap = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 0.0
        layer.lineWidth = 25
        return layer
    }()
    
    private lazy var maxReachedIconView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "trophy"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var valueLabel : EFCountingLabel = {
        let label = EFCountingLabel()
        label.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        label.minimumScaleFactor = 0.75
        label.text = "\(0)"
        label.setUpdateBlock { value, sender in
            label.text = Int(value).formatted(.number)
        }
        return label
    }()
    
    private lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "steps"
        return label
    }()
    
    private lazy var maxValueLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.text = String(format: "%0.0f", self.maxValue)
        return label
    }()
    
    
    private lazy var labelsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [valueLabel, detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var maxReachedStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [maxReachedIconView, maxValueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBottomTrackLayer()
        layoutProgressTrackLayer()
        layoutLabelsStackView()
        layoutMaxReachedStackView()
    }
}

// MARK: - Configuration
extension StepProgressView {
    private func makePath() -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = frame.width * 0.30
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        return path.cgPath
    }
}

// MARK: - Layout
extension StepProgressView {
    private func layoutBottomTrackLayer() {
        bottomTrackLayer.path = makePath()
        layer.addSublayer(bottomTrackLayer)
    }
    
    private func layoutProgressTrackLayer() {
        progressTrackLayer.path = makePath()
        layer.addSublayer(progressTrackLayer)
    }
    
    private func layoutLabelsStackView() {
        addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            labelsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func layoutMaxReachedStackView() {
        addSubview(maxReachedStackView)
        
        NSLayoutConstraint.activate([
            maxReachedStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalToSystemSpacingBelow: maxReachedStackView.bottomAnchor, multiplier: 0),
        ])
    }
}

// MARK: - Private Methods
extension StepProgressView {
    private func setStrokeEndAnimation(start: CGFloat, end: CGFloat, in layer: CAShapeLayer, fillMode: CAMediaTimingFillMode = .forwards){
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.delegate = self
        strokeEnd.fillMode = fillMode
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeEnd.duration = 1.5
        strokeEnd.fromValue  = start
        strokeEnd.toValue = end
        
        layer.strokeEnd = end
        layer.add(strokeEnd, forKey: "progressAnim")
    }
    
}

// MARK: - Public Methods
extension StepProgressView {
    public func updateMaxValue(_ value: CGFloat) {
        self.maxValueLabel.text = Int(value).formatted(.number)
        
        setStrokeEndAnimation(start: currentValue / maxValue , end: currentValue / value, in: progressTrackLayer)
        
        if currentValue <= value {
            didComplete = false
            maxReachedIconView.tintColor = .systemGray3
        }
        
        self.maxValue = value
    }
    
    public func updateProgress(with value: CGFloat){
        let endPosition = value / maxValue
        let startPosition = currentValue / maxValue
        
        self.valueLabel.countFrom(currentValue, to: value)
        
        if !didComplete {
            setStrokeEndAnimation(start: startPosition, end: endPosition, in: progressTrackLayer)
        }
    
        self.currentValue = value
    }
}

// MARK: - Animation Delegate
extension StepProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let anim = anim as? CABasicAnimation, let keypath = anim.keyPath {
            if keypath == "strokeEnd" && currentValue >= maxValue && !didComplete {
                // Set didComplete to true to avoid any extra animations
                didComplete = true
                
                // Remove all of the animations from the layer
                layer.removeAllAnimations()
                
                // Update the tint color for the image view
                maxReachedIconView.tintColor = .systemOrange
                
                // Send true to subscribers of didReachMaxPublisher
                didReachMaxPublisher.send(true)
            }
        }
    }
    
    public func reset() {
        self.didComplete = false
        self.updateProgress(with: 0)
    }
}

// MARK: - Preview
struct StepProgressView_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let stepsProgressView = StepProgressView()
            stepsProgressView.updateMaxValue(7500)
            stepsProgressView.updateProgress(with: 5000)
            
            return stepsProgressView
        }
        .frame(width: .infinity, height: 300)
    }
}
