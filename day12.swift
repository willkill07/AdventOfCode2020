import Foundation

enum Command {
    case moveX(Int)
    case moveY(Int)
    case rotate(Double)
    case move(Int)
    
    static func make(line: Substring) -> Command {
        let num = Int(line.dropFirst())!
        switch line.first {
        case "N": return moveY(num)
        case "S": return moveY(-num)
        case "E": return moveX(num)
        case "W": return moveX(-num)
        case "L": return rotate(Double(num) / 180.0 * Double.pi)
        case "R": return rotate(-Double(num) / 180.0 * Double.pi)
        default: return move(num)
        }
    }
}

class Ship {
    var x : Int = 0
    var y : Int = 0
    init (_ cmds : [Command]) {
        cmds.forEach({apply($0)})
    }
    func apply(_ cmd : Command) {
        fatalError("Must Override")
    }
    var manhattan : Int {
        abs(x) + abs(y)
    }
}

class Ship1 : Ship {
    var dir : Double = 0
    override func apply(_ cmd : Command) {
        switch cmd {
        case .moveX(let dx):
            x += dx
            return
        case .moveY(let dy):
            y += dy
            return
        case .rotate(let rad):
            dir += rad
            return
        case .move(let amount):
            x += amount * Int(cos(dir))
            y += amount * Int(sin(dir))
            return 
        }
    }
}

class Ship2 : Ship {
    var wX : Int = 10
    var wY : Int = 1
    
    override func apply(_ cmd : Command) {
        switch cmd {
        case .moveX(let dx):
            wX += dx
            return 
        case .moveY(let dy):
            wY += dy
            return
        case .rotate(let rad):
            let (cosR, sinR) = (Int(cos(rad)), Int(sin(rad)))
            (wX, wY) = (wX * cosR - wY * sinR, wX * sinR + wY * cosR)
            return
        case .move(let amount):
            x += amount * wX
            y += amount * wY
            return
        }
    }
}

let commands = try! String(contentsOfFile: "day12.txt")
    .split(separator: "\n")
    .map(Command.make)

print(Ship1(commands).manhattan)
print(Ship2(commands).manhattan)
