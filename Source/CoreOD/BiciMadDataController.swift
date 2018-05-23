//
//  BiciMadDataController.swift
//  CoreOD
//
//  Created by Adolfo Vera Blasco on 22/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation

/**
    Gestiona las fuentes de datos para 
    BiciMAD en el Portal de Datos Abiertos
    del Ayuntamiento de Madrid.
*/
public class BiciMadDataController: DataController
{
    /**
        Recupera las subscripciones para un periodo concreto.

        - Parameters:
            - month: Mes de las subscripciones
            - year: El año asociado al mes.
        - Returns: Las subscripciones si las hubiera
    */
    public func subscriptions(by month: Subscription.Month, duringYear year: Int) -> [Subscription]?
    {
        guard let data = super.readData(from: "bicis_usuarios_abonos"),
              let subscriptions = try? super.decoder.decode([Subscription].self, from: data)
         else
        {
            return nil
        }

        return subscriptions.filter(byMonth: month, inYear: year)?.sorted()
    }
}
