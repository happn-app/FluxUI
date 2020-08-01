/*
 * ContentView.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI



struct ContentView: View {
	
	var body: some View {
		VStack{
			MenuButton(label: Text("Select Flux Deployment")){
				Text("http://flux-happn-console.podc.happn.io/api/flux")
			}.padding()
			HStack{
				VStack{
					Text("Deployment")
					List {
					}
					
				}
				VStack{
					Text("Versions")
					List {
					}
				}
			}
		}
	}
	
}


/* *************** */

struct ContentView_Previews : PreviewProvider {
	
	static var previews: some View {
		ContentView()
	}
	
}
