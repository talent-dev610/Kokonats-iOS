//
//  UIImage+extension.swift
//  kokonats
//
//  Created by George on 2022-05-04.
//

import Foundation
import UIKit

extension UIImage
{
    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage
    {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
