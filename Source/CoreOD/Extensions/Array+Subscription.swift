//
//  Array+Subscription.swift
//  BiciKit
//
//  Created by Adolfo Vera Blasco on 22/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation

extension Array where Element == Subscription
{
    /**
        Filtra aquellas subscripciones para un mes y año concreto

        - Parameters:
            - month: Mes solicitado
            - year: Año asociado al mes
        - Returns: Las subscripciones del mes, si las hubiera
    */
    public func filter(byMonth month: Subscription.Month, inYear year: Int) -> [Element]?
    {
        guard let period = month.period(in: year) else 
        {
            return nil
        }
        
        return self.filter({ $0.date >= period.start && $0.date <= period.end })
    }
}
