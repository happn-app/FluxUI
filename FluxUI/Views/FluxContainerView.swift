/*
 * FluxContainersView.swift
 * FluxUI
 *
 * Created by François Lamboley on 03/08/2020.
 */

import Foundation
import SwiftUI



struct FluxContainerView : View {
	
	var fluxContainer: FluxContainer
	
	@State
	var selectedContainer: FluxContainer.ContainerDescription?
	
	var body: some View {
		List(fluxContainer.available ?? [], id: \.self, selection: $selectedContainer){ containerDescription in
			Text(containerDescription.id)
				.foregroundColor(fluxContainer.current.id == containerDescription.id ? .green : .primary)
		}
	}
	
}


/* *************** */

struct FluxContainerView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let images = try! JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "images", withExtension: "json")!))
	
	static var previews: some View {
		FluxContainerView(fluxContainer: images[1].containers[0])
	}
	
}
