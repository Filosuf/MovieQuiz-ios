import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }

    enum YPTheme {
        static var black: UIColor { return UIColor(rgb: 0x1A1B22) }
        static var gray: UIColor { return UIColor(rgb: 0xE6E8EB) }
        static var green: UIColor { return UIColor(rgb: 0x60C28E) }
        static var red: UIColor { return UIColor(rgb: 0xF56B6C) }
        static var white: UIColor { return UIColor(rgb: 0xFFFFFF) }
        static var background: UIColor { return UIColor(red: 26, green: 27, blue: 34, alpha: 0.6) }
    }
}
