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
    public var didReachMax = CurrentValueSubject<CMPedometerData?,Never>(nil)
    
    public var stepData: CMPedometerData? = nil{
        didSet {
            self.updateProgress(stepData?.numberOfSteps.intValue ?? -1)
        }
    }
    
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
        layer.strokeColor = UIColor.systemTeal.withAlphaComponent(0.25).cgColor
        layer.strokeEnd = 1.0
        layer.lineCap = .round
        layer.lineWidth = 32
        return layer
    }()
   
    private lazy var progressLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemTeal.cgColor
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        layer.lineWidth = 25
        return layer
    }()
    
    public lazy var topLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 36, weight: .black)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.text = "\(0)"
        return label
    }()
    
    public lazy var bottomLabel : UILabel = {
        let label = UILabel()
        label.text = "steps"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var didCompleteImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(
            systemName: "crown.fill",
            withConfiguration: UIImage.SymbolConfiguration(textStyle: .title1, scale: .large))
        imageView.tintColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var labelsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var rootStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [didCompleteImageView, labelsStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15
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
    
    // MARK: - Private Methods
    private func makePath() {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: (frame.width - 1.5) * 0.35,
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
        
        NSLayoutConstraint.activate([
            rootStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rootStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
    private func updateProgress( _ value: Int) {
        self.topLabel.text = "\(value == -1 ? 0 : value)"
        
        let fValue = CGFloat(value)
        let basicProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let newStrokeEndPosition = fValue / maxValue
        basicProgressAnimation.fillMode = .forwards
        basicProgressAnimation.isRemovedOnCompletion = false
        basicProgressAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        basicProgressAnimation.duration = 0.9
        basicProgressAnimation.fromValue = currentValue / maxValue
        basicProgressAnimation.toValue = newStrokeEndPosition
        
        progressLayer.strokeEnd = newStrokeEndPosition
        progressLayer.add(basicProgressAnimation, forKey: "progressAnimation")
        
        self.currentValue = fValue
        
        self.checkIfMaxReached()
    }
    
    private func checkIfMaxReached() {
        if Int(currentValue) >= Int(maxValue) {
            didReachMax.send(stepData)
            didCompleteImageView.tintColor = .systemOrange
        } else {
            didCompleteImageView.tintColor = .clear
        }
    }
    
    // MARK: - Public Methods
    public func updateMax(_ max: Int) {
        maxValue = CGFloat(max)
        updateProgress(Int(currentValue))
    }
    
    public func updateData(with pedometerData: CMPedometerData?){
        self.stepData = pedometerData
    }
}
