//
//  Theme.swift
//  BiciBoard
//
//  Created by Adolfo Vera Blasco on 28/8/17.
//  Copyright © 2017 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Foundation

internal class Theme
{
	/**

	*/
	internal enum Mode: Int
	{
		case dark = 0
		case light = 1		
	}

	/**

	*/
	internal enum Tint: String
	{
		case red = "#f72020"
        case pink = "#FF2D55"
        case orange = "#FCB727"
        case green = "#4CD964"
        case blue = "#5AC8FA"
        
        internal var uiColor: UIColor
        {
            return UIColor(hexadecimal: self.rawValue)
        }
	}

	internal static let current: Theme = Theme()

	///
	internal private(set) var background: UIColor!
	///
	internal private(set) var secondaryBackground: UIColor!
	///
	internal private(set) var textColor: UIColor!
	///
	internal private(set) var secondaryTextColor: UIColor!
	///
	internal private(set) var tintColor: UIColor!
	
	///
	internal var mode: Mode
	{
	    didSet
	    {
	     	self.applyMode()   
	    }
	}
	
	///
	internal var tint: Tint
	{
	    didSet
	    {
	        self.applyTint()
	    }
	}
	
	/**
		Initializer

		Por defecto modo **claro** y tinte **azul**
	*/
	private init()
	{
	    self.mode = .light
	    self.tint = .blue
        
        self.applyMode()
	    self.applyTint()
	}

	/**

	*/
	private func applyMode() -> Void
	{
		switch self.mode
        {
            case .dark:
                self.background = UIColor.color(from: "#000000", alpha: 1.0)
                self.secondaryBackground = UIColor.color(from: "#181818", alpha: 1.0)
                self.textColor = UIColor.color(from: "#ffffff", alpha: 1.0)
                self.secondaryTextColor = UIColor.color(from: "#808080", alpha: 1.0)
                
            case .light: 
                self.background = UIColor.color(from: "#ffffff", alpha: 1.0)
                self.secondaryBackground = UIColor.color(from: "#f9f9f9", alpha: 1.0)
                self.textColor = UIColor.color(from: "#000000", alpha: 1.0)
                self.secondaryTextColor = UIColor.color(from: "#9c9698", alpha: 1.0)
        }
        
        UINavigationBar.appearance().barTintColor = self.background
        UINavigationBar.appearance().titleTextAttributes =  [NSAttributedStringKey.foregroundColor: self.textColor]
        UINavigationBar.appearance().largeTitleTextAttributes =  [NSAttributedStringKey.foregroundColor: self.textColor]
        
        UITabBar.appearance().barTintColor = self.background
	}

	/**

	*/
	private func applyTint() -> Void
	{
		self.tintColor = UIColor.color(from: self.tint.rawValue, alpha: 1.0)
        
        UINavigationBar.appearance().tintColor = self.tintColor
        UITabBar.appearance().tintColor = self.tintColor
        
        UIButton.appearance().tintColor = self.tintColor
        UISlider.appearance().tintColor = self.tintColor
        UIStepper.appearance().tintColor = self.tintColor
        UISwitch.appearance().onTintColor = self.tintColor
	}
}
