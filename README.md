# AppleCoding-Reporting
![Swift 4.1](https://img.shields.io/badge/swift-4.1-red.svg) ![Xcode](https://img.shields.io/badge/xcode-9.3-red.svg) ![ChartJS 2.7.2](https://img.shields.io/badge/ChartJS-2.7.2-blue.svg) ![FlexBoxGrid](https://img.shields.io/badge/FlexBoxGrid-6.3.1-blue.svg) ![MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)

Código que acompaña al artículo publicado en Apple Coding sobre reporting en apps iOS y macOS mediante `HTML` y `CSS3`

![Screenshot](https://github.com/fitomad/AppleCoding-Reporting/blob/master/Screenshots/article-reporting-header.jpg)

## Librerías HTML y CSS

Para el diseño de las plantillas con los gráfico es informes hemos usado dos librerías:

* [ChartJS](http://www.chartjs.org) como librería de gráficos
* [FlexBoxGrid](http://flexboxgrid.com) para *grid responsive*

## Registro en EMT Madrid Open Data

Para poder trabajar con el API necesitas estar registrado en portal de Datos Abiertos de la EMT. 

Puedes registrarte [desde este formulario](http://opendata.emtmadrid.es/Formulario.aspx).

Una vez tengas en tu poder el correo de confirmación con tu usuario y contraseña debes editar la clase `BiciMADClient`, situarte en el inicializador de la clase y poner tu usuario y contraseña en la asignación de las variables `apiUser` y `apiPassword`

```swift
private init()
{
	self.decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .formatted(DateFormatter.bicimadISO8601)

	self.baseURI = "https://rbdata.emtmadrid.es:8443/BiciMad"
->	self.apiUser = "### TU_USUARIO_AQUÍ ###"
->	self.apiPassword = "### TU CLAVE_AQUÍ ###"
	...
```

## Cosas Por Hacer (TO-DO)

Algunas cosas se ha quedado sin codificar por motivos de tiempo, algunas de  ellas son...

* Añadir la funcionalidad de marcar estaciones como favoritas
* Poder hacer Back desde el controlador del mapa.


## Contacto

Cualquier duda o sugerencia me puedes encontrar en twitter. [@fitomad](https://twitter.com/fitomad)
