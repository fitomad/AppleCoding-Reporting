//
//  DataController.swift
//  CoreOD
//
//  Created by Adolfo Vera Blasco on 22/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation

/**
    Base para las clases encagardas de manejar los
    datos de un tipo concreto del Portal de Datos
    Abiertos del Ayuntamiento de Madrid.

    La mayoría de estos datos no están disponibles 
    mediante servicio, sino que hay que decargar un 
    archivo que suele requerir de una posterior manipulación.

    La actualización de los datos también varía dependiendo
    de su naturaleza, siendo desde datos en tiempo real a 
    actualizaciones anuales.

    El framework `CoreOD` espera los datos ya transformados
    a un formato JSON.
*/
public class DataController
{
    /// Decodifcador json
    public private(set) var decoder: JSONDecoder
    
    /**
        Preparamos el decodificador
    */
    public init()
    {
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    /**
        Obtiene los datos de uno de los archivos
        de datos.
    */
    internal func readData(from file: String) -> Data?
    {
        let bundle: Bundle = Bundle(for: DataController.self)
        
        guard let file = bundle.path(forResource: file, ofType:"json") else
        {
            return nil
        }
        
        let url  = URL(fileURLWithPath: file)
        
        if let content = try? String(contentsOf: url, encoding: .utf8),
           let data = content.data(using: .utf8)
        {
            return data
        }

        return nil
    }
}
