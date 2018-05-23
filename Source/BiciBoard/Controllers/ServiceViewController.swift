//
//  ServiceViewController.swift
//  BiciBoard
//
//  Created by Adolfo Vera Blasco on 16/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import WebKit
import Foundation

import CoreOD
import BiciKit
import DashboardKit

internal class ServiceViewController: UIViewController
{
    ///
    @IBOutlet private weak var buttonMap: UIBarButtonItem!

    ///
    @IBOutlet private weak var scroolViewContainer: UIScrollView!

    ///
    @IBOutlet private weak var labelStations: UILabel!
    ///
    @IBOutlet private weak var webViewStations: WKWebView!

    ///
    @IBOutlet private weak var labelBikes: UILabel!
    ///
    @IBOutlet private weak var webViewBikes: WKWebView!

    ///
    @IBOutlet private weak var labelOccupation: UILabel!
    ///
    @IBOutlet private weak var webViewOccupation: WKWebView!

    ///
    @IBOutlet private weak var labelCompare: UILabel!
    ///
    @IBOutlet private weak var webViewCompare: WKWebView!

    ///
    @IBOutlet private weak var labelStationsList: UILabel!
    ///
    @IBOutlet private weak var webViewStationsList: WKWebView!

    //
    // MARK: - Life Cycle
    //

    /**
        Cargamos los datos de las estaciones
    */
    override internal func viewDidLoad() -> Void
    {
        super.viewDidLoad()

        self.loadStationsInformation()
    }

    /**
        Aplicamos aspecto visual
    */
    override internal func viewWillAppear(_ animated: Bool) -> Void
    {
        super.viewWillAppear(animated)

        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false

        self.applyTheme()
        self.localizeText()
    }

    //
    // MARK: - Prepare UI
    //

    /**
        El tema UI
    */
    private func applyTheme() -> Void
    {
        self.view.backgroundColor = Theme.current.background
        
        self.labelStations.textColor = Theme.current.textColor
        self.labelBikes.textColor = Theme.current.textColor
        
        self.labelStationsList.textColor = Theme.current.textColor
    }

    /**
        Texto en base al idioma
    */
    private func localizeText() -> Void
    {
        self.title = NSLocalizedString("SERVICE_TITLE", comment: "")
        
        self.labelBikes.text = NSLocalizedString("SERVICE_BIKES_GRAPH_TITLE", comment: "")
        self.labelCompare.text = NSLocalizedString("SERVICE_COMPARATION_GRAPH_TITLE", comment: "")
        self.labelStations.text = NSLocalizedString("SERVICE_STATIONS_GRAPH_TITLE", comment: "")
        self.labelOccupation.text = NSLocalizedString("SERVICE_OCCUPATION_GRAPH_TITLE", comment: "")
        self.labelStationsList.text = NSLocalizedString("SERVICE_STATIONS_LIST_TITLE", comment: "")
    }

    //
    // MARK: - Service Data
    //

    /**
        Solicitamos los datos de todas las estaciones
    */
    private func loadStationsInformation() -> Void
    {
        BiciMADClient.shared.stations() { (result: BiciMADResult) -> Void in
            switch result
            {
                case let .success(stations):
                    DispatchQueue.main.async
                    {
                        // Estaciones
                        self.presentStations(active: stations.stationsAvailables, outOfService: stations.stationsUnavailables)
                        
                        // Bicicletas
                        self.presentBikes(inUse: stations.bikesInUse, availablesInStations: stations.freeBikes)
                        
                        // Ocupacion
                        let low_count = stations.stationsCount(by: .low)
                        let middle_count = stations.stationsCount(by: .medium)
                        let high_count = stations.stationsCount(by: .high)
                        let unavailable_count = stations.stationsCount(by: .unavailable)

                        self.presentOccupation(lowLevel: low_count, medium: middle_count, high: high_count, unavailable: unavailable_count)
                        
                        // Listado
                        let stations_data = stations.map({
                            return (name: $0.name, bikes: $0.bikesDocked, docks: $0.freeBases, occupation: $0.occupationLevel)
                        })

                        self.presentStations(list: stations_data)

                        // Mes anterior
                        let dataController = BiciMadDataController()

                        if let subscriptions = dataController.subscriptions(by: .april, duringYear: 2018)
                        {
                            self.presentSubscriptions(subscriptions, inMonth: "\(Subscription.Month.april)", duringYear: 2018)
                        }                        
                    }   
                case let .error(message):
                    print("Algo pasa con el servicio...")
            }
        }
    }

    //
    // MARK: - Reports
    //

    /**
        Gráfico de estado de las estaciones

        - Parameters:
            - active: Operativas
            - outOfService: Fuera de servicio
    */
    private func presentStations(active: Int, outOfService: Int) -> Void
    {
        guard let htmlCode = ReportEngine.shared.reporForStations(availables: active, outOfService: outOfService) else
        {
            return
        }
        
        self.webViewStations.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    /**
        Gráficos de cantidad de bicicletas

        - Parameters:
            - inUse: Circulando por Madrid
            - availables: Las que se pueden alquilar
    */
    private func presentBikes(inUse: Int, availablesInStations availables: Int) -> Void
    {
        guard let htmlCode = ReportEngine.shared.reportForBikes(inUse: inUse, availables: availables) else
        {
            return
        }
        
        self.webViewBikes.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    /**
        Gráfico con los niveles de ocupación de las estaciones

        - Parameter:
            - low: Baja ocupación
            - medium: Nivel medio
            - high: Alto nivel de ocupación
            - unavailable: No están disponibles
    */
    private func presentOccupation(lowLevel low: Int, medium: Int, high: Int, unavailable: Int) -> Void
    {
        guard let htmlCode = ReportEngine.shared.reportForStations(occupationLow: low, medium: medium, high: high, unavailable: unavailable) else
        {
            return
        }
        
        self.webViewOccupation.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    /**
        Gráfico de subscripciones al servicio BiciMad del mes anterior (abril)

        Muestra los datos para los abonos anuales y los ocasionales.

        - Parameters:
            - subscriptions: Todas las subscripciones
            - month: De que mes queremos extraer los datos
            - year: Y de que año.
    */
    private func presentSubscriptions(_ subscriptions: [Subscription], inMonth month: String, duringYear year: Int) -> Void
    {
        let anual = subscriptions.map({ $0.anualSubscriptions })
        let occasionals = subscriptions.map({ $0.occasionalSubscriptions })

        guard let htmlCode = ReportEngine.shared.reportMonth(month, inYear:year, anualSubscriptions: anual, occasionals: occasionals) else
        {
            return
        }

        self.webViewCompare.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    /**
        Listado de todas las estaciones del servicio.

        Los datos están en un array que contiene tuplas con
        las información que muestro para cada estación

            * name: Nombre de la estación
            * bikes: Las bicis disponibles
            * docks: Los anclajes libres
            * occupation: El nivel de ocupación

        - Parameters:
            list: Los datos de las estaciones
    */
    private func presentStations(list: [(name: String, bikes: Int, docks: Int, occupation: Ocuppation)]) -> Void
    {
        let reportParameters = list.map({ (item: (name: String, bikes: Int, docks: Int, occupation: Ocuppation)) -> StationRecord in
            let reportOccupation = ReportEngine.OcuppationReporting(rawValue: item.occupation.rawValue)!
            
            let parameter: StationRecord = (name: item.name, bikes: item.bikes, docks: item.docks, occupation: reportOccupation)
            
            return parameter
        })

        guard let htmlCode = ReportEngine.shared.reportToList(reportParameters) else
        {
            return
        }

        self.webViewStationsList.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    //
    // MARK: - Actions
    //

    /**
        Mostramos las estaciones sobre un mapa
    */
    @IBAction private func handleMapButtonTap() -> Void
    {
        guard let storyboard = self.storyboard, 
              let stationsViewController = storyboard.instantiateViewController(withIdentifier: "StationsViewController") as? StationsViewController
        else
        {
            return 
        }

        self.navigationController?.pushViewController(stationsViewController, animated: true)
    }
}
