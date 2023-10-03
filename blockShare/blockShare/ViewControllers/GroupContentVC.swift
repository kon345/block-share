//
//  GroupContentVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit
import iOSDropDown

class GroupContentVC: UIViewController {
    // TODO: 假資料
    let category = ["影片", "情報", "梗圖"]
    var pickedCategoryIndex = -1
    var inputURL = ""
    
    var currentGroupID = -1
    // 新增的方塊
    var currentBlock: basicBlock!
    // 當前方塊的左上角
    var topLeftPoint: CGPoint{
        let boardFrame = boardCollectionView.convert(boardCollectionView.frame, to: self.view)
        return CGPoint(x: currentBlock.frame.minX - boardFrame.minX, y: currentBlock.frame.minY - boardFrame.minY)
    }
    
    @IBOutlet weak var categoryDropDown: DropDown!
    @IBOutlet weak var categoryImageView: UIImageView!
    // 版面
    @IBOutlet weak var boardScrollView: UIScrollView!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var newBlockLabel: UILabel!
    @IBOutlet weak var rotateBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var newBlockImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        boardScrollView.delegate = self
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        
        newBlockLabel.isHidden = true
        newBlockImageView.isHidden = true
        newBlockImageView.layer.borderWidth = 2
        newBlockImageView.layer.borderColor = UIColor.gray.cgColor
        rotateBtn.isHidden = true
        confirmBtn.isHidden = true
        
        categoryDropDown.optionArray = category
        categoryDropDown.optionImageArray = categoryImage
        categoryDropDown.didSelect { selectedText, index, id in
            self.pickedCategoryIndex = index
            self.categoryImageView.image = UIImage(named: categoryImage[self.pickedCategoryIndex])
        }
    }
    
    // 確定按鈕按下
    @IBAction func confirmBtnPressed(_ sender: Any) {
        let blockPosition = calculateCurrentBlockPosition()
        if blockPosition.count == 0{
            return
        }
        blockHelper.shared.createBlock(blockContent: blockHelper.shared.newBlockContent, blockCategoryIndex: blockHelper.shared.newBlockCategoryIndex, blockPosition: blockPosition, groupID: currentGroupID) { result, error in
            if let error = error{
                print("create block failed: \(error)")
                return
            }
            guard let blockID = result?.content?.blockID else {
                print("no blockID received")
                return
            }
            print("blockID = \(blockID)")
        }
    }
    
    func calculateCurrentBlockPosition()-> [[Int]]{
        guard let cell = findTopLeftBoardCell(x: topLeftPoint.x, y: topLeftPoint.y),
              let indexPath = boardCollectionView.indexPath(for: cell) else {
            return []
        }
        let startX = indexPath.row % boardRowCount + 1;
        let startY = indexPath.row / boardRowCount + 1;
        
        let rotation = currentBlock.currentRotation
        let diff = rotation.getDiffs()
        let blockPosition = diff.map { (x, y) in
            return [x+startX, y+startY]
        }
        print(blockPosition)
        return blockPosition
    }
    
    // 自動對齊左上方格
    func stickToTopLeftCell(currentCenter: CGPoint){
        guard let cell = findTopLeftBoardCell(x: topLeftPoint.x, y: topLeftPoint.y) else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.currentBlock.center = CGPoint(x: currentCenter.x + (cell.frame.minX - self.topLeftPoint.x) , y: currentCenter.y + (cell.frame.minY - self.topLeftPoint.y))
        }
    }
    
    // 找到左上方格
    func findTopLeftBoardCell(x: CGFloat, y:CGFloat) -> UICollectionViewCell?{
        for cell in boardCollectionView.visibleCells{
            let cellFrame = cell.frame
            if cellFrame.contains(CGPoint(x: x, y: y)){
                return cell
            }
        }
        return nil
    }
    
    // 旋轉按鈕按下
    @IBAction func rotateBtnPressed(_ sender: Any) {
        currentBlock.rotate()
    }
    
    // 產生新方塊（由AddBlockVC呼叫）
    func newBlockCreated(){
        newBlockLabel.isHidden = false
        newBlockImageView.isHidden = false
        rotateBtn.isHidden = false
        confirmBtn.isHidden = false
        let point1 = newBlockImageView.frame.origin
        let point2 = newBlockImageView.center
        let startPoint = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
        currentBlock = blockHelper.shared.createRandomBlock(color: categoryColor[blockHelper.shared.newBlockCategoryIndex], position: startPoint)
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
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "createNewBlock", let addBlockVC = segue.destination as? AddBlockVC{
             addBlockVC.groupContentVC = self
         }
     }
     
    
}

extension GroupContentVC: UIScrollViewDelegate{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let currentBlock = currentBlock{
            stickToTopLeftCell(currentCenter: currentBlock.center)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let currentBlock = currentBlock{
            stickToTopLeftCell(currentCenter: currentBlock.center)
        }
    }
}

// 版面
extension GroupContentVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: 根據資料大小決定
        return 504
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardSquare", for: indexPath)
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
}

