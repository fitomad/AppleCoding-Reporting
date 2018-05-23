//
//  StationsViewController.swift
//  BiciBoard
//
//  Created by Adolfo Vera Blasco on 16/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

import BiciKit
import DashboardKit

internal class StationsViewController: UIViewController
{
    ///
    @IBOutlet private weak var mapViewStations: MKMapView!
    ///
    @IBOutlet private weak var stationViewContainer: UIView!
    
    ///
    private var stationViewController: StationViewController?

    //
    // MARK: - Life Cycle
    //

    /**
        Configuramos el mapa y cargamos las estaciones
    */
    override internal func viewDidLoad() -> Void
    {
        super.viewDidLoad()

        self.configureMap()

        self.loadStations()
    }
    
    /**
        Aplicamos el tema
    */
    override internal func viewWillAppear(_ animated: Bool) -> Void
    {
        super.viewWillAppear(animated)

        self.applyTheme()
        
        // Quiero que el mapa se vea a pantalla completa
        self.navigationController?.isNavigationBarHidden = true

        self.stationViewContainer.alpha = 0.0
    }
    
    /**
        Escondo la vista de detalle estación
    */
    override internal func viewDidAppear(_ animated: Bool) -> Void
    {
        super.viewDidAppear(animated)
        
        self.stationViewContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        self.stationViewContainer.alpha = 1.0
    }
    
    /**
        Le digo al UINavigationController que vuelva a mostrar
        la barra de navegación
    */
    override internal func viewWillDisappear(_ animated: Bool) -> Void
    {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    /**
        Obtenemos la referencia al `UIViewController` que 
        maneja la vista del contenedor
    */
    override internal func prepare(for segue: UIStoryboardSegue, sender: Any?) -> Void
    {
        guard let viewController = segue.destination as? StationViewController, segue.identifier == "StationEmbedSegue" else
        {
            return
        }

        self.stationViewController = viewController
    }
    
    //
    // MARK: - Prepare UI
    //
    
    /**
        Tema visual
    */
    private func applyTheme() -> Void
    {
        self.stationViewContainer.layer.cornerRadius = 8.0
        
        self.stationViewContainer.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
        
        self.stationViewContainer.layer.masksToBounds = true
    }

    /**
        Preparo em mapa
    */
    private func configureMap() -> Void
    {
        self.mapViewStations.showsUserLocation = true
        self.mapViewStations.showsPointsOfInterest = false
        self.mapViewStations.showsCompass = false
        self.mapViewStations.showsScale = true

        self.mapViewStations.register(StationClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
 
        self.mapViewStations.delegate = self
    }

    //
    // MARK: - Data
    //

    /**
        Pedimos los datos de todas las estaciones para mostrarlos
        en el mapa
    */
    private func loadStations() -> Void
    {
        BiciMADClient.shared.stations() { (result: BiciMADResult) -> Void in
            switch result
            {
                case let .success(stations):
                    DispatchQueue.main.async
                    {
                        stations.forEach({ self.addMapPin(forStation: $0) })
                    }   
                case let .error(message):
                    print("Algo pasa con el servicio...")
            }
        }
    }

    /**
        Añade un pin para la estación en el mapa

        - Parameter station: Contiene la localización donde
            situar el pin.
    */
    private func addMapPin(forStation station: Station) -> Void
    {
        let point = StationMapAnnotation(for: station)
        self.mapViewStations.addAnnotation(point)
    }

    //
    // MARK: - Animations
    //

    /*
        Presentamos la información para una nueva estación

        - Parameter station: Datos de la estación
    */
    private func presentData(for station: Station) -> Void
    {
        // Show Animations. After *Hide* animation

        let parameter = UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: CGVector(dx: 0.4, dy: 0.4))

        let presenter = UIViewPropertyAnimator(duration: 0.35, timingParameters: parameter) 

        presenter.addAnimations({
            self.stationViewContainer.transform = CGAffineTransform.identity
        })

        // Hide Animation. The First animation

        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn)

        animator.addAnimations({
            self.stationViewContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        })

        animator.addCompletion({ (position: UIViewAnimatingPosition) -> Void in 
            if position == .end
            {
                // Station from the new Station
                self.stationViewController?.station = station
                // Let's show that data
                presenter.startAnimation()
            }
        })

        animator.startAnimation()
    }
}

//
// MARK: - MKMapViewDelegate Protocol
//

extension StationsViewController : MKMapViewDelegate
{
    /**
        Han pulsado sobre una parada del mapa
    */
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) -> Void
    {
        guard let annotation = view.annotation,
              let station_annotation = annotation as? StationMapAnnotation
        else
        {
            return
        }

        self.presentData(for: station_annotation.station)

        // Ahora centramos el mapa en el pin seleccionado
        mapView.setCenter(annotation.coordinate, animated: true)
    }

    /**
        Le ponemos un pin a cada annotation añadido al mapa
    */
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView!
    {
        guard let annotation = annotation as? StationMapAnnotation else
        {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "StationAnnotation") as? MKMarkerAnnotationView

        if annotationView == nil
        {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier:"StationAnnotation")

            annotationView?.markerTintColor = annotation.annotationColor
            annotationView?.glyphTintColor = UIColor.white
            annotationView?.glyphText = "\(annotation.stationIdentifier)"

            annotationView?.clusteringIdentifier = "BiciMad Stations"
            annotationView?.canShowCallout = false
        }
        else
        {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}
