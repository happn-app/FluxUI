/*
 * FluxWorkloadView.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI



struct FluxWorkloadView : View {
	
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
				FluxContainerView(fluxContainer: container)
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
