//
//  MoofuslistImageNames.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/24/26.
//

actor ImageNames {
  private let imageNames: [String: [String]] = [
    "360-degree view": ["binoculars.fill"],
    "9/11 memorial": ["building.columns.fill"],
    "alcatraz": ["ferry.fill","binoculars.fill","figure.walk"],
    "arcade games": ["gamecontroller.fill"],
    "art": ["photo.artframe"],
    "art exhibits": ["paintpalette.fill"],
    "arts": ["photo.artframe"],
    "aquarium": ["fish.fill"],
    "aquariums": ["fish.fill"],
    "attractions": ["figure.walk"],
    "bakeries": ["birthday.cake"],
    "bars": ["wineglass.fill"],
    "beach": ["beach.umbrella.fill"],
    "beachs": ["beach.umbrella.fill"],
    "beauty salons": ["comb.fill"],
    "bike": ["bicycle"],
    "biking": ["bicycle"],
    "bridge": ["figure.walk"],
    "boat": ["ferry.fill"],
    "bookstore": ["books.vertical.fill","book.pages"],
    "bookstores": ["books.vertical.fill","book.pages"],
    "boutiques": ["handbag.fill"],
    "bowling": ["figure.bowling"],
    "brewery": ["cup.and.saucer.fill"],
    "butterfly exhibit": ["ant.fill", "ladybug.fill"],
    "cable car": ["cablecar.fill"],
    "cable cars": ["cablecar.fill"],
    "cafes": ["cup.and.saucer.fill"],
    "camping": ["tent.2.fill"],
    "cemetery": ["cross.fill"],
    "children's activities": ["figure.child"],
    "chinatown": ["chineseyuanrenminbisign","fork.knife","storefront.fill"],
    "clubs": ["figure.socialdance","music.note.house.fill"],
    "coit tower": ["binoculars.fill"],
    "colleges": ["graduationcap.fill"],
    "comedy clubs": ["person.wave.2.fill"],
    "concert hall": ["music.note.house.fill","music.note.list"],
    "concert halls": ["music.note.house.fill","music.note.list"],
    "dam": ["water.waves","bolt.fill"],
    "dance clubs": ["figure.socialdance"],
    "dining": ["fork.knife"],
    "district": ["storefront.fill"],
    "drive": ["car.fill"],
    "education": ["text.book.closed.fill"],
    "empire state building": ["building.columns.fill", "binoculars.fill"],
    "entertainment": ["popcorn.fill"],
    "events": ["calendar"],
    "ferry": ["ferry.fill"],
    "farmers markets": ["leaf.arrow.trianglehead.clockwise"],
    "festival": ["party.popper.fill"],
    "fishing": ["figure.fishing"],
    "food": ["fork.knife"],
    "food trucks": ["truck.box.fill"],
    "funicular": ["cablecar.fill"],
    "galleries": ["photo.fill.on.rectangle.fill"],
    "garden": ["leaf.fill"],
    "gardens": ["leaf.fill"],
    "golf": ["figure.golf"],
    "graffiti": ["photo.artframe","theatermask.and.paintbrush.fill"],
    "gyms": ["dumbbell.fill"],
    "harbor": ["water.waves"],
    "haight-ashbury": ["figure.walk","binoculars.fill"],
    "healthcare": ["staroflife.shield.fill"],
    "health clinics": ["plus.circle.fill"],
    "hike": ["figure.hiking"],
    "hiking": ["figure.hiking"],
    "historic site": ["building.columns.fill"],
    "historical": ["building.columns.fill"],
    "hot air balloon festival": ["balloon.2.fill"],
    "japanese restaurant": ["fork.knife"],
    "innovation": ["lightbulb.max.fill"],
    "insect exhibit": ["ant.fill", "ladybug.fill"],
    "karaoke": ["music.mic","music.note.house.fill"],
    "lakes": ["water.waves"],
    "landmark": ["building.columns.fill"],
    "landmarks": ["building.columns.fill"],
    "library of congress": ["books.vertical.fill","building.columns.fill"],
    "libraries": ["books.vertical.fill"],
    "little havana": ["storefront.fill","fork.knife"],
    "lombard street": ["road.lanes.curved.right"],
    "lounges": ["sofa.fill"],
    "malls": ["building.2.fill"],
    "market": ["storefront.fill"],
    "massage": ["carseat.right.massage.fill"],
    "medical": ["cross.case.fill"],
    "movies": ["movieclapper.fill","ticket.fill"],
    "murals": ["paintpalette.fill"],
    "museum": ["building.fill"],
    "museums": ["building.2.fill"],
    "museum of art": ["photo.artframe","paintpalette.fill"],
    "music": ["music.pages.fill"],
    "musicals": ["music.note.house.fill"],
    "nature": ["leaf.fill"],
    "nightlife": ["figure.socialdance","moon.stars"],
    "observatory": ["building.columns.fill"],
    "observe": ["binoculars.fill"],
    "outdoor": ["sun.max.fill"],
    "outdoor walk": ["sun.max.fill","figure.walk"],
    "park": ["tree.fill"],
    "parks": ["tree.fill"],
    "photography": ["camera.fill"],
    "pizza": ["fork.knife"],
    "pubs": ["mug.fill"],
    "playgrounds": ["figure.play"],
    "racetrack": ["road.lanes.curved.right"],
    "railway": ["train.side.front.car"],
    "restaurants": ["fork.knife"],
    "scenic": ["binoculars.fill"],
    "scenic views": ["binoculars.fill"],
    "scenic walk": ["binoculars.fill","figure.walk"],
    "schools": ["long.text.page.and.pencil"],
    "science": ["atom"],
    "shop": ["storefront.fill"],
    "shopping": ["storefront.fill","bag.fill"],
    "shops": ["storefront.fill"],
    "sightseeing": ["binoculars.fill"],
    "sightseeing walk": ["binoculars.fill","figure.walk"],
    "skateparks": ["skateboard.fill"],
    "space": ["moon.stars.fill","globe.americas.fill"],
    "sports": ["figure.basketball"],
    "stairs": ["figure.stairs"],
    "state capitol": ["building.columns.fill"],
    "statue of liberty": ["ferry.fill","figure.walk"],
    "stroll": ["figure.walk"],
    "swimming": ["figure.open.water.swim"],
    "tennis": ["figure.tennis","tennis.racket"],
    "theater": ["theatermasks.fill"],
    "theaters": ["theatermasks.fill"],
    "theatre": ["theatermasks.fill"],
    "theme parks": ["ticket.fill"],
    "times square": ["theatermasks.fill","storefront.fill","person.2.badge.plus.fill"],
    "tour": ["figure.walk"],
    "trails": ["figure.hiking"],
    "train": ["tram.fill"],
    "travel": ["airplane"],
    "university": ["graduationcap.fill","books.vertical.fill","building.2.fill"],
    "yoga": ["figure.yoga"],
    "vibrant boardwalk": ["fork.knife","storefront.fill"],
    "views": ["binoculars.fill"],
    "walking": ["figure.walk.motion"],
    "waterfront": ["water.waves"],
    "water taxi": ["ferry.fill"],
    "wharf": ["water.waves"],
    "wildlife": ["pawprint.fill"],
    "zoo": ["pawprint.fill","tortoise.fill","bird.fill"],
    "zoos": ["pawprint.fill","tortoise.fill","bird.fill"]
  ]

  func imageNames(for activity: AIManager.Activity) async -> [String] {
    print("------------------------------")
    let activity = activity.lowercased()
    print(activity)

    var result = [String]()
    result = process(input: activity.name, result: &result)
    result = process(input: activity.category, result: &result)
    result = process(input: activity.description, result: &result)
    result = removeSimilarImages(result: &result)

    if result.count < 1 {
      print(activity)
//      assertionFailure()
      return ["mappin.circle.fill"]
    }
    return result
  }

  func process(input: String, result: inout [String]) -> [String] {
    for (key, imageStrings) in imageNames {
      if input.contains(key) {
        for imageString in imageStrings {
          if result.contains(imageString) { continue }
          result.append(imageString)
        }
      }
    }
    print("input=\(input) \(result)")
    return result
  }

  private func removeSimilarImages(result: inout [String]) -> [String] {
    if result.contains("building.columns.fill") {
      if let idx = result.firstIndex(of: "building.fill") {
        result.remove(at: idx)
      }
    }
    if result.contains("books.vertical.fill") {
      if let idx = result.firstIndex(of: "text.book.closed.fill") {
        result.remove(at: idx)
      }
    }
    if result.contains("building.2.fill") {
      if let idx = result.firstIndex(of: "building.fill") {
        result.remove(at: idx)
      }
    }
    return result
  }
}

/*
 private struct Data {
   let names: [String]
   let systemNames: [String]
 }

 private let imageNames: [String: Data] = [
   "360-degree view":Data(names:["360-degree view"],systemNames:["binoculars.fill"]),
   "9/11 memorial":Data(names:["9/11 memorial"],systemNames:["building.columns.fill"]),
   "alcatraz":Data(names:["Ferry","Binoculars","Walk","Alcatraz"],systemNames: ["ferry.fill","binoculars.fill","figure.walk","building.columns.fill"]),
   "arcade games":Data(names:["Arcade Games"],systemNames:["gamecontroller.fill"]),
   "art":Data(names:["Photo"],systemNames:["photo.artframe"]),
   "art exhibits":Data(names:["Paint Palette"],systemNames:["paintpalette.fill"]),
   "arts":Data(names:["Photo"],systemNames:["photo.artframe"]),
   "aquarium":Data(names:["Aquarium"],systemNames:["fish.fill"]),
   "aquariums":Data(names:["Aquariums"],systemNames:["fish.fill"]),
   "attractions":Data(names:["Attractions"],systemNames:["figure.walk"]),
   "bakeries":Data(names:["Bakeries"],systemNames:["birthday.cake"]),
   "bars":Data(names:["Bars"],systemNames:["wineglass.fill"]),
   "beach":Data(names:["Beach"],systemNames:["beach.umbrella.fill"]),
   "beachs":Data(names:["Beachs"],systemNames:["beach.umbrella.fill"]),
   "beauty salons":Data(names:["Beauty Salons"],systemNames:["comb.fill"]),
   "bike":Data(names:["Bicycle"],systemNames:["bicycle"]),
   "biking":Data(names:["Biking"],systemNames:["bicycle"]),
   "bridge":Data(names:["Bridge"],systemNames:["figure.walk"]),
   "boat":Data(names:["Boat"],systemNames:["ferry.fill"]),
   "bookstore":Data(names:["Books","Book Pages","Bookstores"],systemNames:["books.vertical.fill","book.pages","storefront.fill"]),
   "bookstores":Data(names:["Books","Book Pages","Bookstores"],systemNames:["books.vertical.fill","book.pages","storefront.fill"]),
   "boutiques":Data(names:["Handbag","Boutiques"],systemNames:["handbag.fill","storefront.fill"]),
   "bowling":Data(names:["Bowling"],systemNames:["figure.bowling"]),
   "brewery":Data(names:["Cup And Saucer","Brewery"],systemNames:["cup.and.saucer.fill","building.columns.fill"]),
   "butterfly exhibit":Data(names:["Ant", "Ladybug","Butterfly Exhibit"],systemNames:["ant.fill", "ladybug.fill","photo.artframe"]),
   "cable car":Data(names:["Cablecar"],systemNames:["cablecar.fill"]),
   "cable cars":Data(names:["Cablecars"],systemNames:["cablecar.fill"]),
   "cafes":Data(names:["Cafes"],systemNames:["cup.and.saucer.fill"]),
   "camping":Data(names:["Camping"],systemNames:["tent.2.fill"]),
   "cemetery":Data(names:["Cemetery"],systemNames:["cross.fill"]),




   "children's activities":Data(names:["binoculars"],systemNames:["figure.child"]),
   "chinatown":Data(names:["binoculars"],systemNames:["chineseyuanrenminbisign","fork.knife","storefront.fill"]),
   "clubs":Data(names:["binoculars"],systemNames:["figure.socialdance","music.note.house.fill"]),
   "coit tower":Data(names:["binoculars"],systemNames:["binoculars.fill"]),
   "colleges":Data(names:["binoculars"],systemNames:["graduationcap.fill"]),
   "comedy clubs":Data(names:["binoculars"],systemNames:["person.wave.2.fill"]),
   "concert hall":Data(names:["binoculars"],systemNames:["music.note.house.fill","music.note.list"]),
   "concert halls":Data(names:["binoculars"],systemNames:["music.note.house.fill","music.note.list"]),
   "dance clubs":Data(names:["binoculars"],systemNames:["figure.socialdance"]),
   "dining":Data(names:["binoculars"],systemNames:["fork.knife"]),
   "district":Data(names:["binoculars"],systemNames:["storefront.fill"]),
   "drive":Data(names:["binoculars"],systemNames:["car.fill"]),
   "education":Data(names:["binoculars"],systemNames:["text.book.closed.fill"]),
   "empire state building":Data(names:["building","binoculars"],systemNames:["building.columns.fill", "binoculars.fill"]),
   "entertainment":Data(names:["binoculars"],systemNames:["popcorn.fill"]),
   "events":Data(names:["binoculars"],systemNames:["calendar"]),
   "ferry":Data(names:["binoculars"],systemNames:["ferry.fill"]),
   "farmers markets":Data(names:["binoculars"],systemNames:["leaf.arrow.trianglehead.clockwise"]),
   "festival":Data(names:["binoculars"],systemNames:["party.popper.fill"]),
   "fishing":Data(names:["binoculars"],systemNames:["figure.fishing"]),
   "food":Data(names:["binoculars"],systemNames:["fork.knife"]),
   "food trucks":Data(names:["binoculars"],systemNames:["truck.box.fill"]),
   "funicular":Data(names:["binoculars"],systemNames:["cablecar.fill"]),
   "galleries":Data(names:["binoculars"],systemNames:["photo.fill.on.rectangle.fill"]),
   "garden":Data(names:["binoculars"],systemNames:["leaf.fill"]),
   "gardens":Data(names:["binoculars"],systemNames:["leaf.fill"]),
   "golf":Data(names:["binoculars"],systemNames:["figure.golf"]),
   "graffiti":Data(names:["binoculars"],systemNames:["photo.artframe","theatermask.and.paintbrush.fill"]),
   "gyms":Data(names:["binoculars"],systemNames:["dumbbell.fill"]),
   "harbor":Data(names:["binoculars"],systemNames:["water.waves"]),
   "haight-ashbury":Data(names:["binoculars"],systemNames:["figure.walk","binoculars.fill"]),
   "healthcare":Data(names:["binoculars"],systemNames:["staroflife.shield.fill"]),
   "health clinics":Data(names:["binoculars"],systemNames:["plus.circle.fill"]),
   "hike":Data(names:["binoculars"],systemNames:["figure.hiking"]),
   "hiking":Data(names:["binoculars"],systemNames:["figure.hiking"]),
   "historic site":Data(names:["building"],systemNames:["building.columns.fill"]),
   "historical":Data(names:["building"],systemNames:["building.columns.fill"]),
   "hot air balloon festival":Data(names:["binoculars"],systemNames:["balloon.2.fill"]),
   "innovation":Data(names:["binoculars"],systemNames:["lightbulb.max.fill"]),
   "insect exhibit":Data(names:["binoculars"],systemNames:["ant.fill", "ladybug.fill"]),
   "karaoke":Data(names:["binoculars"],systemNames:["music.mic","music.note.house.fill"]),
   "lakes":Data(names:["binoculars"],systemNames:["water.waves"]),
   "landmark":Data(names:["building"],systemNames:["building.columns.fill"]),
   "landmarks":Data(names:["building"],systemNames:["building.columns.fill"]),
   "library of congress":Data(names:["Books","building"],systemNames:["books.vertical.fill","building.columns.fill"]),
   "libraries":Data(names:["binoculars"],systemNames:["books.vertical.fill"]),
   "little havana":Data(names:["binoculars"],systemNames:["storefront.fill","fork.knife"]),
   "lombard street":Data(names:["binoculars"],systemNames:["road.lanes.curved.right"]),
   "lounges":Data(names:["binoculars"],systemNames:["sofa.fill"]),
   "malls":Data(names:["binoculars"],systemNames:["building.2.fill"]),
   "market":Data(names:["binoculars"],systemNames:["storefront.fill"]),
   "massage":Data(names:["binoculars"],systemNames:["carseat.right.massage.fill"]),
   "medical":Data(names:["binoculars"],systemNames:["cross.case.fill"]),
   "movies":Data(names:["binoculars"],systemNames:["movieclapper.fill","ticket.fill"]),
   "murals":Data(names:["binoculars"],systemNames:["paintpalette.fill"]),
   "museum":Data(names:["binoculars"],systemNames:["building.fill"]),
   "museums":Data(names:["binoculars"],systemNames:["building.2.fill"]),
   "museum of art":Data(names:["binoculars"],systemNames:["photo.artframe","paintpalette.fill"]),
   "music":Data(names:["binoculars"],systemNames:["music.pages.fill"]),
   "musicals":Data(names:["binoculars"],systemNames:["music.note.house.fill"]),
   "nature":Data(names:["binoculars"],systemNames:["leaf.fill"]),
   "nightlife":Data(names:["binoculars"],systemNames:["figure.socialdance","moon.stars"]),
   "observatory":Data(names:["building"],systemNames:["building.columns.fill"]),
   "observe":Data(names:["binoculars"],systemNames:["binoculars.fill"]),
   "outdoor":Data(names:["binoculars"],systemNames:["sun.max.fill"]),
   "outdoor walk":Data(names:["binoculars"],systemNames:["sun.max.fill","figure.walk"]),
   "park":Data(names:["binoculars"],systemNames:["tree.fill"]),
   "parks":Data(names:["binoculars"],systemNames:["tree.fill"]),
   "photography":Data(names:["binoculars"],systemNames:["camera.fill"]),
   "pizza":Data(names:["binoculars"],systemNames:["fork.knife"]),
   "pubs":Data(names:["binoculars"],systemNames:["mug.fill"]),
   "playgrounds":Data(names:["binoculars"],systemNames:["figure.play"]),
   "racetrack":Data(names:["binoculars"],systemNames:["road.lanes.curved.right"]),
   "railway":Data(names:["binoculars"],systemNames:["train.side.front.car"]),
   "restaurants":Data(names:["binoculars"],systemNames:["fork.knife"]),
   "scenic views":Data(names:["binoculars"],systemNames:["binoculars.fill"]),
   "scenic walk":Data(names:["binoculars"],systemNames:["binoculars.fill","figure.walk"]),
   "schools":Data(names:["binoculars"],systemNames:["long.text.page.and.pencil"]),
   "science":Data(names:["binoculars"],systemNames:["atom"]),
   "shop":Data(names:["binoculars"],systemNames:["storefront.fill"]),
   "shopping":Data(names:["binoculars"],systemNames:["storefront.fill","bag.fill"]),
   "shops":Data(names:["binoculars"],systemNames:["storefront.fill"]),
   "sightseeing":Data(names:["binoculars"],systemNames:["binoculars.fill"]),
   "sightseeing walk":Data(names:["binoculars"],systemNames:["binoculars.fill","figure.walk"]),
   "skateparks":Data(names:["binoculars"],systemNames:["skateboard.fill"]),
   "space":Data(names:["binoculars"],systemNames:["moon.stars.fill","globe.americas.fill"]),
   "sports":Data(names:["binoculars"],systemNames:["figure.basketball"]),
   "stairs":Data(names:["binoculars"],systemNames:["figure.stairs"]),
   "state capitol":Data(names:["building"],systemNames:["building.columns.fill"]),
   "statue of liberty":Data(names:["binoculars"],systemNames:["ferry.fill","figure.walk"]),
   "stroll":Data(names:["binoculars"],systemNames:["figure.walk"]),
   "swimming":Data(names:["binoculars"],systemNames:["figure.open.water.swim"]),
   "tennis":Data(names:["binoculars"],systemNames:["figure.tennis","tennis.racket"]),
   "theater":Data(names:["binoculars"],systemNames:["theatermasks.fill"]),
   "theaters":Data(names:["binoculars"],systemNames:["theatermasks.fill"]),
   "theatre":Data(names:["binoculars"],systemNames:["theatermasks.fill"]),
   "theme parks":Data(names:["binoculars"],systemNames:["ticket.fill"]),
   "times square":Data(names:["binoculars"],systemNames:["theatermasks.fill","storefront.fill","person.2.badge.plus.fill"]),
   "tour":Data(names:["binoculars"],systemNames:["figure.walk"]),
   "trails":Data(names:["binoculars"],systemNames:["figure.hiking"]),
   "travel":Data(names:["binoculars"],systemNames:["airplane"]),
   "university":Data(names:["binoculars"],systemNames:["graduationcap.fill","books.vertical.fill","building.2.fill"]),
   "yoga":Data(names:["binoculars"],systemNames:["figure.yoga"]),
   "vibrant boardwalk":Data(names:["binoculars"],systemNames:["fork.knife","storefront.fill"]),
   "views":Data(names:["binoculars"],systemNames:["binoculars.fill"]),
   "walking":Data(names:["binoculars"],systemNames:["figure.walk.motion"]),
   "waterfront":Data(names:["binoculars"],systemNames:["water.waves"]),
   "wharf":Data(names:["binoculars"],systemNames:["water.waves"]),
   "wildlife":Data(names:["binoculars"],systemNames:["pawprint.fill"]),
   "zoo":Data(names:["binoculars"],systemNames:["pawprint.fill","tortoise.fill","bird.fill"]),
   "zoos":Data(names:["binoculars"],systemNames:["pawprint.fill","tortoise.fill","bird.fill"])
 ]

 */
