//
//  StepsProgressView.swift
//  Pedestrian
//
//  Created by J Manuel Zaragoza on 1/1/23.
//

import UIKit

class StepProgressView: UIView {
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
        layer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.25).cgColor
        layer.strokeEnd = 1.0
        layer.lineCap = .round
        layer.lineWidth = 25
        return layer
    }()
   
    private lazy var progressLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        layer.lineWidth = 18
        return layer
    }()
    
    public lazy var topLabel : UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 32, weight: .black)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    public lazy var bottomLabel : UILabel = {
        let label = UILabel()
        label.text = "steps"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
        
        makePath()
        layoutLabels()
    }
    
    // MARK: - Private Methods
    private func makePath() {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: (frame.width - 1.5) * 0.40,
            startAngle: startPoint,
            endAngle: endPoint,
            clockwise: true)
        
        bottomLayer.path = path.cgPath
        layer.addSublayer(bottomLayer)
        
        progressLayer.path = path.cgPath
        layer.addSublayer(progressLayer)
    }
    
    private func layoutLabels() {
        addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            labelsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelsStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    public func updateMax(_ max: CGFloat) {
        self.maxValue = max
    }
    
    public func updateProgress( _ value: Int) {
        topLabel.text = "\(value)"
        
        let fValue = CGFloat(value)
        let basicProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let newStrokeEndPosition = fValue / maxValue
        basicProgressAnimation.fillMode = .forwards
        basicProgressAnimation.isRemovedOnCompletion = false
        basicProgressAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        basicProgressAnimation.duration = 0.5
        basicProgressAnimation.fromValue = currentValue / maxValue
        basicProgressAnimation.toValue = newStrokeEndPosition
        progressLayer.strokeEnd = newStrokeEndPosition
        progressLayer.add(basicProgressAnimation, forKey: "progressAnimation")
        self.currentValue = fValue
    }
}
