//
//  GroupContentVC.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/8.
//

import UIKit
import iOSDropDown

class GroupContentVC: UIViewController {
    // 群組分類
    var category: [String] = []
    // 被選取的分類(沒有為-1)
    var pickedCategoryIndex = -1
    // 點擊的方塊URL
    var selectedBlockURL = ""
    // 當前群組代碼
    var currentGroupID = -1
    // 新增的方塊
    var currentBlock: basicBlock!
    // 新增方塊的左上角
    var topLeftPoint: CGPoint{
        let boardFrame = boardCollectionView.convert(boardCollectionView.frame, to: self.view)
        return CGPoint(x: currentBlock.frame.minX - boardFrame.minX, y: currentBlock.frame.minY - boardFrame.minY)
    }
    
    enum textMessage: String{
        case positionOccupiedPleaseRefresh = "位置已被放置，請重新整理版面再試。"
        case createBlockFailed = "新方塊放置失敗"
        case getBlockListFailed = "取得所有方塊失敗"
        case confirm = "確定"
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
        
        hideNewBlockUI()
        newBlockImageView.layer.borderWidth = 2
        newBlockImageView.layer.borderColor = UIColor.gray.cgColor
        
        // 背景按鈕樣式處理
        commonHelper.shared.assignbackground(view: self.view, backgroundName: "GroupContentBackround")
        navigationController?.navigationBar.tintColor = UIColor.purple
        commonHelper.shared.setPurpleOrangeBtn(button: shareBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: rotateBtn)
        commonHelper.shared.setPurpleOrangeBtn(button: confirmBtn)
        
        guard currentGroupID != -1 else{
            print("no groupID!")
            return
        }
        
        // 藉由群組ID取得分類
        if let groupData = GroupHelper.shared.groupListData.first(where: { group in
            group.groupID == currentGroupID
        }){
            category = groupData.category
            // 添加「無篩選」分類
            category.insert("無篩選", at: 0)
        }else{
            print("groupData missing!: groupID = \(currentGroupID)")
            return
        }
        
        categoryDropDown.optionArray = category
        categoryDropDown.optionImageArray = groupContentCategoryImage
        categoryDropDown.didSelect { selectedText, index, id in
            // 因為添加「無篩選」分類
            self.pickedCategoryIndex = index - 1
            if self.pickedCategoryIndex >= 0 {
                self.categoryImageView.image = UIImage(named: groupContentCategoryImage[self.pickedCategoryIndex+1])
                self.categoryImageView.layer.borderColor = UIColor.black.cgColor
                self.categoryImageView.layer.borderWidth = 1
            } else {
                self.categoryImageView.image = nil
                self.categoryImageView.layer.borderWidth = 0
            }
            self.boardCollectionView.reloadData()
        }
        getBlockList()
    }
    
    // 確定放置按鈕按下
    @IBAction func confirmBtnPressed(_ sender: Any) {
        let blockPosition = calculateCurrentBlockPosition()
        if blockPosition.count == 0{
            print("no Block Position!")
            return
        }
        blockHelper.shared.createBlock(blockContent: blockHelper.shared.newBlockContent, blockCategoryIndex: blockHelper.shared.newBlockCategoryIndex, blockPosition: blockPosition, groupID: currentGroupID) { result, error in
            if let error = error{
                print("create block failed: \(error)")
                return
            }
            
            // 自訂error處理
            if result?.response.success == false, let errorCode = result?.response.errorCode{
                // 位置佔用提示
                if errorCode == "Position is occupied."{
                    DispatchQueue.main.async {
                        commonHelper.shared.showToastGlobal(message: textMessage.positionOccupiedPleaseRefresh.rawValue)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = commonHelper.shared.createAlert(title: textMessage.createBlockFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                    self.present(alert, animated: true)
                }
                return
            }
            
            guard (result?.content?.blockID) != nil else {
                print("no blockID received")
                return
            }
            
            // 清空新增方塊資料
            blockHelper.shared.resetNewBlockData()
            DispatchQueue.main.async {
                // 隱藏新增方塊相關UI
                self.hideNewBlockUI()
                self.shareBtn.isEnabled = true
            }
            // 刷新版面
            self.getBlockList()
        }
    }
    
    @IBAction func refreshBtnPressed(_ sender: Any) {
        getBlockList()
    }
    
    // API取得所有方塊資料
    func getBlockList(){
        // 沒有當前群組代碼
        guard currentGroupID != -1 else{
            print("no groupID!")
            return
        }
        blockHelper.shared.getBlockList(groupID: currentGroupID, blockID: 0) { result, error in
            if let error = error{
                print("get block list failed: \(error)")
                return
            }
            
            // 自訂error處理
            if result?.response.success == false, let errorCode = result?.response.errorCode{
                // 沒有方塊
                if errorCode == "no Block in group."{
                    blockHelper.shared.BlockListData = []
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = commonHelper.shared.createAlert(title: textMessage.getBlockListFailed.rawValue, message: handleResponseError(errorMessage: errorCode), buttonTitle: textMessage.confirm.rawValue)
                    self.present(alert, animated: true)
                }
                return
            }
            
            guard let blockListData = result?.content else{
                print("no blockListData!")
                return
            }
            blockHelper.shared.BlockListData = blockListData
            DispatchQueue.main.async {
                if let currentBlock = self.currentBlock{
                    currentBlock.isHidden = true
                }
                self.boardCollectionView.reloadData()
            }
        }
    }
    
    // 計算新增方塊的座標
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
        shareBtn.isEnabled = false
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
        currentBlock.isHidden = false
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
            let finalCenter = currentBlock.center
            stickToTopLeftCell(currentCenter: finalCenter)
        }
    }
    
    // 隱藏新增方塊相關UI
    func hideNewBlockUI(){
        newBlockLabel.isHidden = true
        newBlockImageView.isHidden = true
        rotateBtn.isHidden = true
        confirmBtn.isHidden = true
    }
    
    // 決定添加邊框方向
    func determineBorderSide(selfIndexPath: Int, allIndexPathList:[Int]) -> [ViewSide]{
        var addBorderSideList: [ViewSide] = []
        if allIndexPathList.contains(selfIndexPath - boardRowCount) == false{
            addBorderSideList.append(.Top)
        }
        if allIndexPathList.contains(selfIndexPath - 1) == false{
            addBorderSideList.append(.Left)
        }
        if allIndexPathList.contains(selfIndexPath + 1) == false{
            addBorderSideList.append(.Right)
        }
        if allIndexPathList.contains(selfIndexPath + boardRowCount) == false{
            addBorderSideList.append(.Bottom)
        }
        return addBorderSideList
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 創建方塊
        if segue.identifier == "createNewBlock", let addBlockVC = segue.destination as? AddBlockVC{
            addBlockVC.groupContentVC = self
            addBlockVC.category = category
        }
        
        // 顯示方塊內容
        if segue.identifier == "showBlockContent", let blockContentVC = segue.destination as? BlockContentVC{
            blockContentVC.URLString = selectedBlockURL
        }
    }
    
    
}

// MARK: ScrollView滾動貼齊
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

// MARK: 版面CollectionView
extension GroupContentVC: UICollectionViewDataSource, UICollectionViewDelegate{
    // 版面數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let maxRow = blockHelper.shared.getBlockMaxRow()
        return maxRow > boardMinRowCount ? (maxRow + boardEmptyRowCount) * boardRowCount : boardMinRowCount * boardRowCount
    }
    
    // 方格顯示塗色加邊框
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptySquare", for: indexPath)
        emptyCell.layer.borderColor = UIColor.lightGray.cgColor
        emptyCell.layer.borderWidth = emptyBorderWidth
        var cell: UICollectionViewCell = emptyCell
        blockHelper.shared.BlockListData.forEach { blockData in
            var indexPathList: [Int] = []
            // 取得一個方塊的所有indexPath.row位置
            blockData.blockPosition.forEach { position in
                let x = position[0] - 1
                let y = position[1] - 1
                let trueIndexPath = y*boardRowCount+x
                indexPathList.append(trueIndexPath)
            }
            
            for(index, _) in blockData.blockPosition.enumerated(){
                let selfIndexPath = indexPathList[index]
                // 取得加邊框的方向
                let addBorderSideList = determineBorderSide(selfIndexPath: selfIndexPath, allIndexPathList: indexPathList)
                if indexPath.row == selfIndexPath{
                    let otherCategoryBlockIndexPathList = blockHelper.shared.getOtherCategoryBlockPositions(currentCategoryIndex: pickedCategoryIndex)
                    if otherCategoryBlockIndexPathList.contains(selfIndexPath){
                        let grayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "grayCell", for: indexPath) as! ColoredBlockCell
                        grayCell.backgroundColor = UIColor.gray
                        // 加邊框
                        addBorderSideList.forEach { viewSide in
                            grayCell.addBorder(toSide: viewSide, withColor: UIColor.black.cgColor, andThickness: coloredBorderWidth)
                        }
                        cell = grayCell
                    } else {
                        // 如果是對應的方塊設成coloredCell
                        let coloredCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(blockData.blockCategoryIndex)", for: indexPath) as! ColoredBlockCell
                        // 塗色
                        coloredCell.backgroundColor = categoryColor[blockData.blockCategoryIndex]
                        // 加邊框
                        addBorderSideList.forEach { viewSide in
                            coloredCell.addBorder(toSide: viewSide, withColor: UIColor.black.cgColor, andThickness: coloredBorderWidth)
                        }
                        cell = coloredCell
                    }
                }
            }
        }
        return cell
    }
    
    // 點擊方格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 沒有放置方塊不做事
        guard let blockData = blockHelper.shared.findBlock(indexPathRow: indexPath.row) else{
            return
        }
        // 取得內容URL
        selectedBlockURL = blockData.blockContent
        // 跳轉前往方塊內容VC
        self.performSegue(withIdentifier: "showBlockContent", sender: nil)
    }
}

// MARK: 自訂cell class
class ColoredBlockCell: UICollectionViewCell{
    // 添加的邊框列表
    var addedSubLayerList: [CALayer] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeBorders()
    }
    
    // 添加邊框
    // @param side
    // @param color
    // @param thickness
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left: border.frame = CGRect(x: 0, y: 0, width: thickness, height: bounds.height); break
        case .Right: border.frame = CGRect(x: bounds.width - thickness, y: 0, width: thickness, height: bounds.height); break
        case .Top: border.frame = CGRect(x: 0, y: 0, width: bounds.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: 0, y: bounds.height - thickness, width: bounds.width, height: thickness); break
        }
        
        layer.addSublayer(border)
        addedSubLayerList.append(border)
    }
    
    // 清理邊框
    func removeBorders(){
        addedSubLayerList.forEach { layer in
            layer.removeFromSuperlayer()
        }
    }
}

