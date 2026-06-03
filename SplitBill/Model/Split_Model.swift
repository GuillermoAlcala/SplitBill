//
//  Split_Model.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import Foundation
import SwiftData
@Model
class Split_Model: Identifiable{
    var id               : UUID = UUID()
    var amount           : Double
    var numberOfPeople   : Int
    var tip              : Tip = Tip.ZeroPercent
   // var total            : Double
    var currentDate      : Date = Date()
    
    
    //calcular el total con impuestos
    var totalAmount: Double{
    
        let cleanTax   = tip.rawValue.replacingOccurrences(of: "%", with: "") //limpiamos el string del enum
        let taxValue   = (Double(cleanTax) ?? 0) / 100 //convertimos a Double
        let iva        = amount * taxValue //calculamos el iva
        let finaltotal = amount + iva      //calculamos el total
        
        return finaltotal
    }
    
    var totalPerson: Double{
        guard numberOfPeople > 0 else{
            return 0
        }
        return totalAmount / Double(numberOfPeople)
    }
    
    init(id : UUID, amount: Double, numberOfPeople: Int, tip: Tip,
         //total: Double,
         currentDate: Date = .now){
        self.id = id
        self.amount = amount
        self.numberOfPeople = numberOfPeople
        self.tip = tip
      //  self.total = total
        self.currentDate = currentDate
    }
    
    
    enum Tip: String, Codable, CaseIterable, Identifiable{
        case ZeroPercent    = "0%"
        case FivePercent    = "5%"
        case TenPercent     = "10%"
        case FifteenPercent = "15%"
        
        var id: String{self.rawValue}
        
    }
}


