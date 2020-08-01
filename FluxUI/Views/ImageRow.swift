/*
 * ImageRow.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI

import XibLoc



struct ImageRow : View {
	
	var image: FluxImage
	
	var body: some View {
		HStack {
			Text(image.id).bold().padding()
			Spacer()
			Text(localizedNContainersString).padding()
		}
	}
	
	var localizedNContainersString: String {
		NSLocalizedString("#n# container<:s>", comment: "The number of containers").applyingCommonTokens(number: XibLocNumber(image.containers.count))
	}
	
}


/* *************** */

struct ImageRow_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let images = try! JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "images", withExtension: "json")!))
	
	static var previews: some View {
		ImageRow(image: images[0])
	}
	
}
