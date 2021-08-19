//
//  main.swift
//  CreditCardGenerator
//
//  Created by Pasca Alberto, IT on 30/07/21.
//

import Foundation

enum CreditCardNumberType: String {
    case Visa
    case Visa13Digit
    case MasterCard
    case Discover
    case AmericanExpress
    case DinersClubUSA
    case DinersClubCanada
    case DinersClubInternational
    case DinersClubCarteBlanche
    case JCB
}

func generateCreditCardNumber(for type: CreditCardNumberType) -> String{
    /* Obtain proper card length */
    var cardLength = (type == .Visa13Digit) ? 13 : 16
    cardLength = (type == .AmericanExpress) ? 15 : cardLength
    cardLength = (type == .DinersClubInternational || type == .DinersClubCarteBlanche) ? 14 : cardLength
    
    var cardNumber = [Int](repeating: 0, count: cardLength)
    var startingIndex = 0
    
    /* Conform to rules for beginning card numbers */
    if type == .Visa || type == .Visa13Digit {
        cardNumber[0] = 4
        startingIndex = 1
    }
    else if type == .MasterCard {
        cardNumber[0] = 5
        cardNumber[1] = Int(arc4random_uniform(5) + 1)
        startingIndex = 2
    }
    else if type == .Discover {
        cardNumber.replaceSubrange(Range(0...3), with: [6,0,1,1])
        startingIndex = 4
    }
    else if type == .AmericanExpress {
        cardNumber.replaceSubrange(Range(0...1), with: [3,4])
        startingIndex = 2
    }
    else if type == .DinersClubUSA || type == .DinersClubCanada {
        //Will most often pass as a master card because of the 54
        cardNumber.replaceSubrange(Range(0...1), with: [5,4])
        startingIndex = 2
    }
    else if type == .DinersClubInternational {
        cardNumber.replaceSubrange(Range(0...1), with: [3,6])
        startingIndex = 2
    }
    else if type == .DinersClubCarteBlanche {
        cardNumber.replaceSubrange(Range(0...2), with: [3,0,0])
        startingIndex = 3
    }
    else if type == .JCB {
        cardNumber.replaceSubrange(Range(0...3), with: [3,5,2,8])
        startingIndex = 4
    }
    
    /* Fill array with random numbers 0-9 */
    for i in startingIndex..<cardNumber.count{
        cardNumber[i] = Int(arc4random_uniform(10))
    }
    
    /* Calculate the final digit using a custom variation of Luhn's formula
     This way we dont have to spend time reversing the array
     */
    let offset = (cardNumber.count+1)%2
    var sum = 0
    for i in 0..<cardNumber.count-1 {
        if ((i+offset) % 2) == 1 {
            var temp = cardNumber[i] * 2
            if temp > 9{
                temp -= 9
            }
            sum += temp
        }
        else{
            sum += cardNumber[i]
        }
    }
    
    let finalDigit = (10 - (sum % 10)) % 10
    cardNumber[cardNumber.count-1] = finalDigit
    
    //Convert cardnumber array to string
    return cardNumber.map({ String($0) }).joined(separator: "")
}

class ArgumentsManager {
    
    private(set) var argsDict: [String: String] = [:]
    
    private func usage() {
        print("Credit Card number generator v1.0");
        print("\nCard Types:")
        print("\t - Visa")
        print("\t - Visa13Digit")
        print("\t - MasterCard")
        print("\t - Discover")
        print("\t - AmericanExpress")
        print("\t - DinersClubUSA")
        print("\t - DinersClubCanada")
        print("\t - DinersClubInternational")
        print("\t - DinersClubCarteBlanche")
        print("\t - JCB\n")
        print("Usage: cc --type cardType\n");
    }
    
    func check() {
        if CommandLine.arguments.count < 2 {
            usage()
            exit(1)
        }
        
        var arrArguments = CommandLine.arguments
        arrArguments.removeFirst()
        
        argsDict["type"]  = arrArguments[1]
    }
    
}

let args = ArgumentsManager()
args.check()

if let type = args.argsDict["type"] {
    if let ccType = CreditCardNumberType(rawValue: type) {
        let number = generateCreditCardNumber(for: ccType)
        print( "\(type): \(number)" )
    }
}
