/*
 * SimpleError.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import Foundation



struct SimpleError : Error, CustomStringConvertible, CustomDebugStringConvertible {
	
	var message: String
	
	var description: String {
		return message
	}
	
	var debugDescription: String {
		return "SimpleError: \(message)"
	}
	
}
