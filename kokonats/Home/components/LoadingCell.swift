//
//  LoadingCell.swift
//  kokonats
//
//  Created by iori on 2022/03/06.
//

import UIKit

class LoadingCell: UITableViewCell {

    private var indicator = UIActivityIndicatorView(style: .medium)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        indicator.hidesWhenStopped = true
        indicator.color = .white
        contentView.addSubview(indicator)
        indicator.activeConstraints(to: contentView, directions: [.centerX, .centerY])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.stopAnimating()
    }

    func confiture(isLoading: Bool) {
        if isLoading {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    private func startAnimating() {
        indicator.startAnimating()
    }
    
    private func stopAnimating() {
        indicator.stopAnimating()
    }
}
