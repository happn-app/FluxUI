/*
 * ContentView.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI



struct ContentView : View {
	
	@ObservedObject
	var fluxWorkloads: FluxWorkloadsViewModel
	
	var body: some View {
		WorkloadNavigationView(fluxWorkloads: fluxWorkloads)
		/* When we have macOS 11 compatibility. */
//		.toolbar(items: {
//			ToolbarItem {
//				/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
//			}
//		})
	}
	
}


/* *************** */

struct ContentView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		let m = FluxWorkloadsViewModel()
		m.workloads = .success(workloads)
		return ContentView(fluxWorkloads: m)
	}
	
}
