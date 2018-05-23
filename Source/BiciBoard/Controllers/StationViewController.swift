//
//  StationViewController.swift
//  BiciBoard
//
//  Created by Adolfo Vera Blasco on 16/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import WebKit
import Foundation

import BiciKit
import DashboardKit

internal class StationViewController: UIViewController
{
    ///
    @IBOutlet private weak var labelStationName: UILabel!
    ///
    @IBOutlet private weak var labelAddress: UILabel!

    ///
    @IBOutlet private weak var buttonFavorite: UIButton!

    ///
    @IBOutlet private weak var labelBikesCount: UILabel!
    ///
    @IBOutlet private weak var labelBikesTitle: UILabel!
    ///
    @IBOutlet private weak var viewBikesMarker: UIView!
    ///
    @IBOutlet private weak var viewBikesContainer: UIView!
    
    ///
    @IBOutlet private weak var labelDocksCount: UILabel!
    ///
    @IBOutlet private weak var labelDocksTitle: UILabel!
    ///
    @IBOutlet private weak var viewDocksMarker: UIView!
    ///
    @IBOutlet private weak var viewDocksContainer: UIView!

    ///
    @IBOutlet private weak var webViewReport: WKWebView!

    ///
    internal var station: Station?
    {
        didSet
        {
            if let station = self.station
            {
                self.loadData(forStation: station)
            }
        }
    }

    //
    // MARK: - Life Cycle
    //

    /**

    */
    override internal func viewDidLoad() -> Void
    {
        super.viewDidLoad()
    }

    /**

    */
    override internal func viewWillAppear(_ animated: Bool) -> Void
    {
        super.viewWillAppear(animated)

        self.applyTheme()
        self.localizeText()
    }

    //
    // MARK: - Prepare UI
    //

    /**

    */
    private func applyTheme() -> Void
    {
        self.view.backgroundColor = Theme.current.background

        self.labelAddress.textColor = Theme.current.secondaryTextColor
        
        self.labelBikesCount.textColor = Theme.current.textColor
        self.labelBikesTitle.textColor = Theme.current.secondaryTextColor
        self.labelDocksCount.textColor = Theme.current.textColor
        self.labelDocksTitle.textColor = Theme.current.secondaryTextColor

        self.viewDocksMarker.backgroundColor = Theme.Tint.blue.uiColor
        self.viewDocksMarker.layer.cornerRadius = self.viewDocksMarker.bounds.height / 2.0
        self.viewDocksMarker.layer.masksToBounds = true
        self.viewDocksContainer.backgroundColor = Theme.current.background

        self.viewBikesMarker.backgroundColor = Theme.Tint.green.uiColor
        self.viewBikesMarker.layer.cornerRadius = self.viewDocksMarker.bounds.height / 2.0
        self.viewBikesMarker.layer.masksToBounds = true
        self.viewBikesContainer.backgroundColor = Theme.current.background
    }

    /**

    */
    private func localizeText() -> Void
    {
        self.labelBikesTitle.text = NSLocalizedString("STATION_BIKE_TITLE", comment: "")
        self.labelDocksTitle.text = NSLocalizedString("STATION_DOCK_TITLE", comment: "")
    }

    //
    // MARK: - Data
    //

    /**
        Muestra los datos de la estación en pantalla
    */
    private func loadData(forStation station: Station) -> Void
    {
        self.labelStationName.text = station.name
        self.labelAddress.text = station.address

        self.labelBikesCount.text = "\(station.bikesDocked)"
        self.labelDocksCount.text = "\(station.freeBases)"
        
        self.showChart(forFreeBikes: station.bikesDocked, freeDocks: station.freeBases)
    }

    /**
        Construye el gráfico asociado a la estación

        - Parameters:
            - bikes: Bicis en la estación
            - docks: Anclajes disponibles
    */
    private func showChart(forFreeBikes bikes: Int, freeDocks docks: Int) -> Void
    {
        guard let htmlCode = ReportEngine.shared.reportForStation(bikesAvailables: bikes, freeDocks: docks) else
        {
            return
        }
        
        self.webViewReport.loadHTMLString(htmlCode, baseURL: ReportEngine.shared.baseURL)
    }

    //
    // MARK: - Actions
    //

    /**
        Marca o desmarca la estación como favorita
    */
    @IBAction private func handleFavoriteButtonTap(sender: UIButton) -> Void
    {
        // Por desarrollar
    }
}
