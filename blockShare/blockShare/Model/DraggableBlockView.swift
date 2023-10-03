//
//  DraggableBlockView.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/30.
//

import UIKit

protocol block{
    var squares: tetrisSquares {get set}
    var color: UIColor {get set}
    var rotations: [blockRotation] {get}
    var currentRotationIndex: Int {get set}
    var startPosition: CGPoint {get set}
    
    func setFrame()
    
    func setSquare()
}

struct Square{
    var row: Int
    var column: Int
    init(_ column: Int = 0, _ row: Int = 0){
        self.row = row
        self.column = column
    }
}

struct tetrisSquares{
    var firstSquare = Square()
    var secondSquare = Square()
    var thirdSquare = Square()
    var fourthSquare = Square()
    
    // 取整個block寬度
    func getWidth() -> Int{
        let allSquare = [firstSquare, secondSquare, thirdSquare, fourthSquare]
        var maxRow = 0
        for square in allSquare {
            if square.row + 1 > maxRow{
                maxRow = square.row + 1
            }
        }
        return maxRow
    }
    
    // 取整個block長度
    func getHeight() -> Int{
        let allSquare = [firstSquare, secondSquare, thirdSquare, fourthSquare]
        var maxColumn = 0
        for square in allSquare {
            if square.column + 1 > maxColumn{
                maxColumn = square.column + 1
            }
        }
        return maxColumn
    }
}

struct blockRotation{
    var squares = tetrisSquares()
    init(_ firstSquare: Square,_ secondSquare: Square,_ thirdSquare: Square,_ fourthSquare: Square){
        squares.firstSquare = firstSquare
        squares.secondSquare = secondSquare
        squares.thirdSquare = thirdSquare
        squares.fourthSquare = fourthSquare
    }
    
    // 計算方塊差距
    func getDiffs() -> [(Int,Int)]{
        let diff2x = squares.secondSquare.row - squares.firstSquare.row
        let diff2y = squares.secondSquare.column - squares.firstSquare.column
        let diff3x = squares.thirdSquare.row - squares.firstSquare.row
        let diff3y = squares.thirdSquare.column - squares.firstSquare.column
        let diff4x = squares.fourthSquare.row - squares.firstSquare.row
        let diff4y = squares.fourthSquare.column - squares.firstSquare.column
        return[(0,0),(diff2x,diff2y),(diff3x,diff3y),(diff4x,diff4y)]
    }
}

class basicBlock: UIImageView, block{
    
    var squares: tetrisSquares = tetrisSquares()
    var color: UIColor = UIColor.black
    var rotations: [blockRotation] = [blockRotation]()
    var currentRotationIndex: Int = 0
    var startPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    var currentRotation: blockRotation{
        return rotations[currentRotationIndex]
    }
    
    var blockWidth: Int {
        return currentRotation.squares.getWidth()
    }
    
    var blockHeight: Int {
        return currentRotation.squares.getHeight()
    }
    
    func setRotations(rotations: [blockRotation]){
        self.rotations = rotations
    }
    
    func rotate(){
        if currentRotationIndex == rotations.count - 1{
            currentRotationIndex = 0
        } else {
            currentRotationIndex += 1
        }
        self.transform = CGAffineTransformRotate(self.transform, CGFloat.pi/2)
        self.setSquare()
    }
    
    
    func setFrame(){
        self.frame = CGRect(x: startPosition.x, y: startPosition.y, width: CGFloat(blockWidth)*squareSize, height: CGFloat(blockHeight)*squareSize)
    }
    
    func setSquare(){
        squares.firstSquare.row = currentRotation.squares.firstSquare.row
        squares.firstSquare.column = currentRotation.squares.firstSquare.column
        squares.secondSquare.row = currentRotation.squares.secondSquare.row
        squares.secondSquare.column = currentRotation.squares.secondSquare.column
        squares.thirdSquare.row = currentRotation.squares.thirdSquare.row
        squares.thirdSquare.column = currentRotation.squares.thirdSquare.column
        squares.fourthSquare.row = currentRotation.squares.fourthSquare.row
        squares.fourthSquare.column = currentRotation.squares.fourthSquare.column
    }
    
    func generateSquares(){
        let firstSquare = BlockDrawer.drawSquare(x:(CGFloat(squares.firstSquare.row) * squareSize), y: (CGFloat(squares.firstSquare.column) * squareSize), squareSize: squareSize, color: color)
        let secondSquare = BlockDrawer.drawSquare(x:(CGFloat(squares.secondSquare.row) * squareSize), y: (CGFloat(squares.secondSquare.column) * squareSize), squareSize: squareSize, color: color)
        let thirdSquare = BlockDrawer.drawSquare(x:(CGFloat(squares.thirdSquare.row) * squareSize), y: (CGFloat(squares.thirdSquare.column) * squareSize), squareSize: squareSize, color: color)
        let fourthSquare = BlockDrawer.drawSquare(x: (CGFloat(squares.fourthSquare.row) * squareSize), y: (CGFloat(squares.fourthSquare.column) * squareSize), squareSize: squareSize, color: color)
        self.addSubview(firstSquare)
        self.addSubview(secondSquare)
        self.addSubview(thirdSquare)
        self.addSubview(fourthSquare)
    }
}

class IBlock: basicBlock{
    let allRotations: [blockRotation] = [blockRotation(Square(0,0),Square(0,1),Square(0,2),Square(0,3)), blockRotation(Square(0,0),Square(1,0),Square(2,0),Square(3,0))]
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class SquareBlock: basicBlock{
    let allRotations: [blockRotation] = [blockRotation(Square(0,0),Square(0,1),Square(1,0),Square(1,1))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class TBlock: basicBlock {
    let allRotations: [blockRotation] = [blockRotation(Square(1,0), Square(0,1), Square(1,1), Square(2,1)), blockRotation(Square(0,0), Square(0,1), Square(1,1), Square(0,2)), blockRotation(Square(0,0), Square(1,0), Square(2,0), Square(1,1)), blockRotation(Square(1,0), Square(0,1), Square(1,1), Square(1,2))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class leftZBlock: basicBlock {
    let allRotations: [blockRotation] = [blockRotation(Square(0,0), Square(0,1), Square(1,1), Square(1,2)), blockRotation(Square(0,1), Square(0,2), Square(1,0), Square(1,1))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class rightZBlock: basicBlock {
    let allRotations: [blockRotation] = [blockRotation(Square(1,0), Square(0,1), Square(1,1), Square(0,2)), blockRotation(Square(0,0), Square(1,0), Square(1,1), Square(2,1))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class leftLBlock: basicBlock {
    let allRotations: [blockRotation] = [blockRotation(Square(0,0), Square(1,0), Square(1,1), Square(1,2)), blockRotation(Square(2,0), Square(0,1), Square(1,1), Square(1,2)), blockRotation(Square(0,0), Square(0,1), Square(0,2), Square(1,2)), blockRotation(Square(0,0), Square(1,0), Square(2,0), Square(0,1))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}

class rightLBlock: basicBlock {
    let allRotations: [blockRotation] = [blockRotation(Square(0,0), Square(1,0), Square(0,1), Square(0,2)), blockRotation(Square(0,0), Square(1,0), Square(2,0), Square(2,1)), blockRotation(Square(1,0), Square(1,1), Square(0,2), Square(1,2)), blockRotation(Square(0,0), Square(0,1), Square(1,1), Square(2,1))]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(color: UIColor, startPosition: CGPoint){
        super.init(frame: .zero)
        
        self.color = color
        self.startPosition = startPosition
        
        self.setRotations(rotations:  allRotations)
        
        self.setFrame()
        
        self.setSquare()
        
        self.generateSquares()
    }
}
