//
//  Subscription.swift
//  BiciKit
//
//  Created by Adolfo Vera Blasco on 22/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation

/**
    Subscripcion al servicio BiciMAD.

    Asociada al fuente de datos **bicis_usuarios_abonos**
*/
public struct Subscription: Codable
{
    /// fechas de los datos
    public var date: Date
    /// Subscripciones nuevas anuales
    public var anualSubscriptions: Int
    /// Subscripciones nuevas ocasionales
    public var occasionalSubscriptions: Int
    /// Total de Subscripciones para este día
    public var dailyTotalSubscriptions: Int
    /// Acumulado de subscripciones nuevas anuales
    public var accumulatedAnualSubscriptions: Int
    /// Acumulado de subscripciones nuevas ocasionales
    public var accumulatedOccasionalSubscriptions: Int
    /// Acumulado de total de subscripciones
    public var accumulatedTotalSubscriptions: Int

    /**
        Set the JSON key values.
    */
	private enum CodingKeys: String, CodingKey
	{
	    case date = "date"
        case anualSubscriptions = "daily_anual_subscriptions"
	    case occasionalSubscriptions = "daily_occasional_subscriptions"
        case dailyTotalSubscriptions = "daily_sum_subscriptions"
        case accumulatedAnualSubscriptions = "accumulated_anual_subscriptions"
	    case accumulatedOccasionalSubscriptions = "accumulated_occasional_subscriptions"
        case accumulatedTotalSubscriptions = "accumulated_total_subscriptions"
	}
}

//
// MARK: - Computed properties
//

extension Subscription
{
    /// Formato corto de fecha. Se usa en el gráfico
    public var shortReportDateFormatted: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"

        return formatter.string(from: self.date)
    }
}

//
// MARK: - Month filtering helper enumeration
//

extension Subscription 
{
    /**

    */
    public enum Month: Int
    {
        case january = 1
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
        
        /**
            Contruye un period que comprende el
            primer y último día del mes.
        */
        internal func period(in year: Int) -> (start: Date, end: Date)?
        {
            var last_day: Int
            
            switch self
            {
                case .january, .march, .may, .july, .august, .october, .december:
                    last_day = 31
                case .april, .june, .september, .november:
                    last_day = 30
                case .february:
                    last_day = (year % 400 == 0) || ((year % 4 == 0) && (year % 100 != 0)) ? 29 : 28
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ss"
            formatter.locale = Locale(identifier: "es_ES")
            
            if let start = formatter.date(from: "1/\(self.rawValue)/\(year)T00:00:00"), let end = formatter.date(from: "\(last_day)/\(self.rawValue)/\(year)T23:59:59")
            {
                return (start: start, end: end)
            }
            
            return nil
        }
    }
}

//
// MARK : - Equatable protocol
//

extension Subscription: Equatable
{
    public static func ==(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return lhs.date == rhs.date
    }

    public static func !=(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return !(lhs == rhs)
    }
}

//
// MARK : - Comparable protocol
//

extension Subscription: Comparable
{
    public static func <(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return lhs.date < rhs.date
    }

    public static func <=(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return lhs.date <= rhs.date
    }

    public static func >(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return lhs.date > rhs.date
    }

    public static func >=(lhs: Subscription, rhs: Subscription) -> Bool
    {
        return lhs.date >= rhs.date
    }
}
