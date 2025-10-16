//
//  MatrixRainView.swift
//  TMRain
//
//  Created by linghugoogle on 2025/10/16.
//

import UIKit

class MatrixRainView: UIView {
    
    private var displayLink: CADisplayLink?
    private var columns: [MatrixColumn] = []
    private let fontSize: CGFloat = 16
    private let font: UIFont
    private var columnWidth: CGFloat = 0
    private var numberOfColumns: Int = 0
    private var numberOfRows: Int = 0
    
    private let characterSet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    override init(frame: CGRect) {
        self.font = UIFont.systemFont(ofSize: fontSize)
        super.init(frame: frame)
        setupMatrix()
    }
    
    required init?(coder: NSCoder) {
        self.font = UIFont.systemFont(ofSize: fontSize)
        super.init(coder: coder)
        setupMatrix()
    }
    
    private func setupMatrix() {
        let sampleText = "M" as NSString
        let textSize = sampleText.size(withAttributes: [.font: font])
        columnWidth = textSize.width
        numberOfColumns = Int(bounds.width / columnWidth)
        numberOfRows = Int(ceil(bounds.height / textSize.height))
        
        setupColumns()
    }
    
    private func setupColumns() {
        columns.removeAll()
        
        for i in 0..<numberOfColumns {
            let column = MatrixColumn(
                x: CGFloat(i) * columnWidth,
                maxRows: numberOfRows,
                characterSet: characterSet
            )
            columns.append(column)
        }
    }
    
    func startAnimation() {
        stopAnimation()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.preferredFramesPerSecond = 15 // 控制帧率
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateAnimation() {
        for column in columns {
            column.update()
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.black.cgColor)
        context.fill(rect)
        
        for column in columns {
            drawColumn(column, in: context)
        }
    }
    
    private func drawColumn(_ column: MatrixColumn, in context: CGContext) {
        let sampleText = "M" as NSString
        let textSize = sampleText.size(withAttributes: [.font: font])
        let characterHeight = textSize.height
        
        for (index, char) in column.characters.enumerated() {
            let y = CGFloat(index) * characterHeight
            
            let alpha = column.getAlphaForIndex(index)
            let color = column.getColorForIndex(index).withAlphaComponent(alpha)
            
            let finalAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]
            
            let charString = String(char) as NSString
            let drawPoint = CGPoint(x: column.x, y: y)
            charString.draw(at: drawPoint, withAttributes: finalAttributes)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMatrix()
    }
    
    deinit {
        stopAnimation()
    }
}

class MatrixColumn {
    let x: CGFloat
    let maxRows: Int
    let characterSet: String
    
    private(set) var chars: [Character] = []
    private var speed: Int
    private var currentRow: Int = 0
    private var trailLength: Int
    
    init(x: CGFloat, maxRows: Int, characterSet: String) {
        self.x = x
        self.maxRows = maxRows
        self.characterSet = characterSet
        self.speed = Int.random(in: 1...3)
        self.trailLength = Int.random(in: 10...30)
        
        generateNewSequence()
    }
    
    private func generateNewSequence() {
        chars.removeAll()
        let sequenceLength = Int.random(in: trailLength...(trailLength + 10))
        
        for _ in 0..<sequenceLength {
            let randomIndex = Int.random(in: 0..<characterSet.count)
            let char = characterSet[characterSet.index(characterSet.startIndex, offsetBy: randomIndex)]
            chars.append(char)
        }
        
        currentRow = -chars.count
    }
    
    func update() {
        currentRow += speed
        
        if currentRow > maxRows {
            generateNewSequence()
            if Int.random(in: 0...100) < 5 {
                currentRow = -Int.random(in: 5...15)
            }
        }
    }
    
    func getAlphaForIndex(_ index: Int) -> CGFloat {
        let relativeIndex = index - currentRow
        
        if relativeIndex < 0 || relativeIndex >= chars.count {
            return 0.0
        }
        
        if relativeIndex == 0 {
            return 1.0
        }
        
        let fadeRatio = 1.0 - (CGFloat(relativeIndex) / CGFloat(chars.count))
        return max(0.1, fadeRatio)
    }
    
    func getColorForIndex(_ index: Int) -> UIColor {
        let relativeIndex = index - currentRow
        
        if relativeIndex < 0 || relativeIndex >= chars.count {
            return UIColor.clear
        }
        
        return UIColor.green
    }
    
    var characters: [Character] {
        var result: [Character] = Array(repeating: " ", count: maxRows)
        
        for (charIndex, char) in chars.enumerated() {
            let screenIndex = currentRow + charIndex
            if screenIndex >= 0 && screenIndex < maxRows {
                result[screenIndex] = char
            }
        }
        
        return result
    }
}

