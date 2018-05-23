
import Foundation

/**
    Tipo de datos para el listado de estaciones
*/
public typealias StationRecord = (name: String, bikes: Int, docks: Int, occupation: ReportEngine.OcuppationReporting)


public class ReportEngine
{
    /**

    */
    public enum OcuppationReporting: Int
    {
        case low = 0
        case medium = 1
        case high = 2
        case unavailable = 3
    }

    /// URL base para los recursos de las plantillas
    public let baseURL: URL
    
    /**
        Los diferentes tipos de plantillas
	*/
    private enum TemplateType: String
	{
        case bikes = "bikes"
        case month = "month"
        case occupation = "occupation"
        case station = "station"
		case stations = "stations"
        case list = "list"
        case listRow = "list-row"
	}

    /// Singleton
    public static let shared = ReportEngine()

    /**
        Establece la URL base
    */
    private init()
    {
        self.baseURL = Bundle.main.resourceURL!
    }

    //
    // MARK: - Reports
    //

    /**
        Plantilla de uso de biciletas en un momento dado
    */
    public func reportForBikes(inUse used: Int, availables: Int) -> String?
    {
        guard let template = self.loadTemplate(ofType: .bikes) else
        {
            return nil
        }
        
        let dataArray = self.makeChartDataArray(for: [ availables, used ])
        let content = String(format: template, "\(availables)", "\(used)", dataArray)
        
        return content
    }

    /**
        Plantilla con el nivel de ocupación de las estaciones
    */
    public func reportForStations(occupationLow low: Int, medium: Int, high: Int, unavailable: Int) -> String?
    {
        guard let template = self.loadTemplate(ofType: .occupation) else
        {
            return nil
        }
        
        let dataArray = self.makeChartDataArray(for: [ low, medium, high, unavailable ])
        let content = String(format: template, "\(low)", "\(medium)", "\(high)", "\(unavailable)", dataArray)
        
        return content
    }

    /**
        Plantillas con el estado de las estaciones
    */
    public func reporForStations(availables: Int, outOfService unavailables: Int) -> String?
    {
        guard let template = self.loadTemplate(ofType: .stations) else
        {
            return nil
        }
        
        let dataArray = self.makeChartDataArray(for: [ availables, unavailables ])
        let content = String(format: template, "\(availables)", "\(unavailables)", dataArray)
        
        return content
    }

    /**
        Plantillas de una estación
    */
    public func reportForStation(bikesAvailables bikes: Int, freeDocks docks: Int) -> String?
    {
        guard let template = self.loadTemplate(ofType: .station) else
        {
            return nil
        }
        
        let dataArray = self.makeChartDataArray(for: [ docks, bikes ])
        let content = String(format: template, dataArray)
        
        return content
    }

    /**
        Plantillas para las susbcripciones al servicio durante un mes
    */
    public func reportMonth(_ month: String, inYear year: Int, anualSubscriptions anual: [Int], occasionals: [Int]) -> String?
    {
        guard let template = self.loadTemplate(ofType: .month) else
        {
            return nil
        }

        let anual_data = self.makeChartDataArray(for: anual)
        let occasional_data = self.makeChartDataArray(for: occasionals)

        let content = String(format: template, month, "\(year)", anual_data, occasional_data)
        
        return content
    }

    /**
        Plantilla con el listado de estaciones y su estado
    */
    public func reportToList(_ stations: [StationRecord]) -> String?
    {
        guard let mainTemplate = self.loadTemplate(ofType: .list),
              let rowTemplate = self.loadTemplate(ofType: .listRow) 
        else
        {
            return nil
        }

        let rows = stations
            .map({
                var ocuppation_style = ""

                switch $0.occupation
                {
                    case .low:
                        ocuppation_style = "low-occupation"
                    case .medium:
                        ocuppation_style = "middle-occupation"
                    case .high:
                        ocuppation_style = "high-occupation"
                    case .unavailable:
                        ocuppation_style = "offline-occupation"
                }

                let row = String(format: rowTemplate, ocuppation_style, "\($0.name)", "\($0.bikes)", "\($0.docks)")

                return row
            })
            .reduce("") { $0 + $1 }

        let content = String(format: mainTemplate, rows)

        return content
    }

    //
	// MARK: - Template Constructor Methods
	//

	/**
        Obtiene el contenido de un archivo `HTML` que 
        tiene la plantilla que nos solicitan

        - Parameter type: La plantilla que vamos a usar
	*/
	private func loadTemplate(ofType type: TemplateType) -> String?
	{
        guard let template_url = Bundle(for: ReportEngine.self).url(forResource: type.rawValue, withExtension: "html"),
              let template_data = try? Data(contentsOf: template_url),
              let template = String(data: template_data, encoding: .utf8)
        else
        {
            return nil
        }
        
        return template as String
	}

    /**
        Convierte un array de `Int` en el formato
        esperado por el librería de gráficos
    */
    private func makeChartDataArray(for array: [Int]) -> String
    {
        let chartData = array.reduce("") { 
            if $0.isEmpty
            {
                return "\($1)"
            }
            else
            {
                return "\($0), \($1)"
            }
        }

        return chartData
    }

    /**
        Converite un array de `String` al formato
        esperado por la librería de gráficos
    */
    private func makeTitleArray(for array: [String]) -> String
    {
        let chartTitles = array.reduce("") {
            if $0.isEmpty
            {
                return "\"\($1)\""
            }
            else
            {
                return "\($0), \"\($1)\""
            }
        }
        
        return chartTitles
    }
}
