////  TagListCollectionView.swift
//  kokonats
//
//  Created by sean on 2021/11/08.
//  
//

import Foundation
import UIKit

protocol TagSelectionDelegate: AnyObject {
    func tagDidSelected(_ view: UIView, tag: String?)
}

class TagListContainerView: UIView {
    private var tagList = [String]()
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout?
    private var selectedIndexPath: IndexPath?
    var delegate: TagSelectionDelegate?
    private var needAllTag: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.layout = layout

        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")
        collectionView.backgroundColor = .kokoBgColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        self.addSubview(collectionView)
        collectionView.activeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateData(tagList: [String], needAllTag: Bool = true) {
        self.needAllTag = needAllTag
        if needAllTag {
            self.tagList = ["all_tag".localized]
        }
        self.tagList.append(contentsOf: tagList)
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
}

extension TagListContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }

    var numberOfSections: Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell {
            let tag = tagList[indexPath.row]
            cell.configure(with: tag)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TagListContainerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !needAllTag {
            delegate?.tagDidSelected(self, tag: tagList[indexPath.item])
        } else {
            let selectedTag: String? =  indexPath.item == 0 ? nil : tagList[indexPath.item]
            delegate?.tagDidSelected(self, tag: selectedTag)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 38)
    }
}
