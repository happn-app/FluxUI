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

import LegibleError



struct FluxWorkloadView : View {
	
	var fluxSettings: FluxSettings?
	
	var fluxWorkload: FluxWorkload
	
	@ObservedObject
	var fluxContainers: FluxContainersViewModel
	
	var body: some View {
		VStack{
			HStack{
				Text(fluxWorkload.id).font(.title).padding()
				Spacer()
			}
			HStack{
				Text("Status: \(fluxWorkload.status.rawValue)").padding(.leading)
				Spacer()
			}
			HStack{
				Text("Rollout: desired \(fluxWorkload.rollout.desired), updated \(fluxWorkload.rollout.updated), ready \(fluxWorkload.rollout.ready), available \(fluxWorkload.rollout.available), outdated \(fluxWorkload.rollout.outdated)").padding(.leading)
				Spacer()
			}
			switch fluxContainers.containers {
				case .success(let containers) where containers.isEmpty: noContainersView
				case .success(let containers):                          containersView(containers)
				case .failure(let error):                               errorView(error)
			}
		}
		.onAppear{
			fluxContainers.load()
		}
	}
	
	func errorView(_ error: Error) -> some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Text(error.legibleLocalizedDescription)
				Spacer()
			}
			Spacer()
		}
	}
	
	func containersView(_ containers: [FluxContainer]) -> some View {
		TabView{
			ForEach(containers, id: \.name){ container in
				FluxContainerView(fluxContainer: container, parentWorkload: fluxWorkload, settings: fluxSettings)
					.tabItem{ Text(container.name) }
			}
		}
	}
	
	var noContainersView: some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Text("No containers found.").bold()
				Spacer()
			}
			Spacer()
		}
	}
	
}


/* *************** */

struct FluxWorkloadView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let images = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "images", withExtension: "json")!))
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))

	static var previews: some View {
		let w = workloads[0]
		
		let m = FluxContainersViewModel(workloadID: workloads[0].id)
		m.containers = .success(images[0].containers)
		
		return FluxWorkloadView(fluxWorkload: w, fluxContainers: m)
	}
	
}
