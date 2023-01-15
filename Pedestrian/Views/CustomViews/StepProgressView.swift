//
//  StepsProgressView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit
import Combine
import CoreMotion

class StepProgressView: UIView {
    // MARK: - Public Properties
    public var didReachMax = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Properties
    private var startPoint = CGFloat(-Double.pi * 0.5)
    
    private var endPoint: CGFloat {
        return  (-startPoint * 3)
    }
    
    private var maxValue: CGFloat = 0.0
    
    private var currentValue: CGFloat = 0.0
    
    // MARK: - UI
    private lazy var bottomLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemPink.withAlphaComponent(0.25).cgColor
        layer.strokeEnd = 1.0
        layer.lineCap = .round
        layer.lineWidth = 33
        return layer
    }()
   
    private lazy var progressLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemPink.cgColor
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        layer.lineWidth = 23
        return layer
    }()
    
    public lazy var stepCountLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 36, weight: .black)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.text = "\(0)"
        return label
    }()
    
    public lazy var stepsLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.text = "steps"
        return label
    }()
    
    public lazy var goalReachedLabel : UILabel = {
        let label = UILabel()
        label.text = "Goal Reached"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var didCompleteImageView : UIImageView = {
        let imageView = UIImageView(image:  UIImage(systemName: "crown.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var bottomStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [didCompleteImageView, goalReachedLabel])
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stepCountLabel, stepsLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life cycle
    convenience init(max: Int) {
        self.init(frame: .zero)
        self.maxValue = CGFloat(max)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makePath()
        layoutLabels()
    }
    
    // MARK: - Layout
    private func makePath() {
        let radius = (frame.width - 1.5) * 0.33
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: startPoint,
            endAngle: endPoint,
            clockwise: true)
        
        bottomLayer.path = path.cgPath
        layer.addSublayer(bottomLayer)
        
        progressLayer.path = path.cgPath
        layer.addSublayer(progressLayer)
    }
    
    private func layoutLabels() {
        addSubview(rootStackView)
        addSubview(bottomStackView)
        NSLayoutConstraint.activate([
            rootStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rootStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            bottomStackView.topAnchor.constraint(equalToSystemSpacingBelow: rootStackView.bottomAnchor, multiplier: 2.5),
            bottomStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func updateProgress(_ value: CGFloat) {
        let endPosition = value / maxValue
        let startPosition = currentValue / maxValue
        
        setStrokeEndAnimation(start: startPosition, end: endPosition, in: progressLayer)
        
        
        self.stepCountLabel.text = Int(value).formatted(.number)
        self.currentValue = value
        self.didReachMax(value: value)
    }
    
    private func setStrokeEndAnimation(start: CGFloat, end: CGFloat, in layer: CAShapeLayer){
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeEnd.duration = 1.5
        strokeEnd.fromValue  = start
        strokeEnd.toValue = end
        
        layer.strokeEnd = end
        layer.add(strokeEnd, forKey: "progressAnim")
    }
    
    private func didReachMax(value: CGFloat) {
        if Int(value) >= Int(maxValue){
            didReachMax.send(true)
            didCompleteImageView.isHidden = false
            goalReachedLabel.isHidden = false
        } else {
            goalReachedLabel.isHidden = true
            didCompleteImageView.isHidden = true
        }
    }
    
    // MARK: - Public Methods
    public func updateValue(_ value: Int){
        let progressValue: CGFloat = CGFloat(value)
        updateProgress(progressValue)
    }
    
    public func setProgressColor(_ color: UIColor){
        bottomLayer.strokeColor = color.withAlphaComponent(0.25).cgColor
        progressLayer.strokeColor = color.cgColor
    }
}
