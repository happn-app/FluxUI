/*
Copyright 2020 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

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
