//
//  GroupContentVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit

class GroupContentVC: UIViewController {
    var currentBlock: basicBlock!
    var touchLocation: CGPoint!
    
    var topLeftPoint: CGPoint{
        let boardFrame = boardCollectionView.convert(boardCollectionView.frame, to: self.view)
        return CGPoint(x: currentBlock.frame.minX - boardFrame.minX, y: currentBlock.frame.minY - boardFrame.minY)
    }
    
    @IBOutlet weak var boardScrollView: UIScrollView!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        boardScrollView.delegate = self
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
    }
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        currentBlock = rightLBlock(color: UIColor.green, startPosition: CGPoint(x: 50, y: 50))
        currentBlock.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)))
        currentBlock.isUserInteractionEnabled = true
        view.addSubview(currentBlock)
    }
    
    
    // 處理拖動
    var initialCenter = CGPoint()
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
        if gesture.state == .began{
            initialCenter = currentBlock.center
        }
        else if gesture.state == .changed {
            let translation = gesture.translation(in: self.view)
            currentBlock.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)}
        else if gesture.state == .ended{
            print("ended")
            let finalCenter = currentBlock.center
            stickToTopLeftCell(currentCenter: finalCenter)
        }
    }
    
    func stickToTopLeftCell(currentCenter: CGPoint){
        guard let cell = findTopLeftBoardCell(x: topLeftPoint.x, y: topLeftPoint.y) else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.currentBlock.center = CGPoint(x: currentCenter.x + (cell.frame.minX - self.topLeftPoint.x) , y: currentCenter.y + (cell.frame.minY - self.topLeftPoint.y))
        }
    }
    
    
    func findTopLeftBoardCell(x: CGFloat, y:CGFloat) -> UICollectionViewCell?{
        for cell in boardCollectionView.visibleCells{
            let cellFrame = cell.frame
            if cellFrame.contains(CGPoint(x: x, y: y)){
                return cell
            }
        }
        return nil
    }
    
    @IBAction func rotateBtnPressed(_ sender: Any) {
        currentBlock.rotate()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GroupContentVC: UIScrollViewDelegate{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate{
            print("scroll ended")
            stickToTopLeftCell(currentCenter: currentBlock.center)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll ended decelerate")
        stickToTopLeftCell(currentCenter: currentBlock.center)
    }
}

// 版面
extension GroupContentVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardSquare", for: indexPath)
//        cell.backgroundColor = .red
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }

}

