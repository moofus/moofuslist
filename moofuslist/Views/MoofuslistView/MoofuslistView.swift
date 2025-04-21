//
//  TrackerView.swift
//  Tracker
//
//  Created by Lamar Williams III on 4/13/25.
//

import SwiftUI

struct MoofuslistView: View {
  @State var viewModel: MoofuslistViewModel

  init() {
    let stream = AsyncStream.makeStream(of: MoofuslistSource.State.self)
    viewModel = .init(stream: stream, viewSource: MoofuslistSource(continuation: stream.continuation))
  }
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      List(activityList) { activityList in
        
        Section(header: Text(activityList.formattedDate)) {
          ForEach(activityList.activities) { activity in
            Text(activity.name)
          }
        }
        .textCase(.none)
      }
      
      Button {
//        AddItemView()
      } label: {
        Image(systemName: "plus")
      }
      .font(.title)
      .padding(.trailing, 20)
    }
  }
}

struct Menus {
  
}
#Preview {
  MoofuslistView()
}
