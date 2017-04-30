# Airport look up app

### Wildcard

* Added Instagram stroy just for fun.

Vimeo link:
[https://vimeo.com/214344362](https://vimeo.com/214344362)


### Version 2.1

* Use Mapbox iOS SDK instead of default Apple maps, improved UI design

![Imgur]
(http://i.imgur.com/jYzFiV2.jpg)

![Imgur]
(http://i.imgur.com/uxcVWnZ.jpg)

* Known issue for this version(no issue for version 2.0, caused by Mapbox I suppose): somehow Mapbox's annotations only include annotations that are visible(probably because it's still view based in essence), this may fail to update airports when they become invisible before they can be updated.

### Version 2.0

* When User click the reset button in the bottom right corner, it will reset to user's current location together with the pin

* Dragging the pin is kind of hard to perform for users due to the size of pin, instead, I modified the logic to dragging the map and the pin will be centered in the map view

* Added current location text display and closest airport location text display

### Version 1.0

Vimeo link: [https://vimeo.com/213892924](https://vimeo.com/213892924)

### Platform

* iOS >= 9.0, if your iPhone/iPad version is 10.3, you'll need to update Xcode to the newest version in order to deploy the App to your device

### Features

* Create a map view which displays all the airports which have "AP_TYPE": "large\_airport”

* Add a “draggable” pin to the map, user can drag this pin to other spots on the map

* Pin is placed at the user’s current location when the app is first opened *(make sure you agree to the location access)* , and upon dragging the pin, its location will be updated and the map will also be re-centered

* Display the “nearest” airport to the pin, it will show as a blue annotation on the map, click the airport for more details(name, location, GPS code, Google search result, etc)

* All airports are always be visible on map, but in the same view, a user should know which airport is closest to their pin, in other word, in a single view, there must be one airport that is marked as blue, even if you don't see the user's pin on the map

* “Nearest” airport display should update each time the pin is finished being dragged

* The “nearest” airport is the one which has the smallest distance from the pin (I used Distance function from Swift directly)

* Add tutorial pop up page to instruct user the functioanlities of this App. 

### How to run

Make sure you open the AirportLookUp.xcworkspace(white background) instead of AirportLookUp.xcodeproj(blue background), if you decide to run it on emulator, select the emulator and you're all set, otherwise you'll need to set Deployment Target(Click project - under Target click AirportLookUp - under Deployment info) to match your physcial device's system version(see Settings - General - About - Version), you also need to trust your signing team in your device, it's under General - Profiles and Device Management - Developer App, trust your email address.

### Sidenotes 

* If you're running the App on a fresh new emulator device, first run the system Maps App for a minute until it downlaod maps, after that open this App, otherwise it would show empty maps

* I have experienced situtaion that sometimes the first time you run the App on a device/emulator, the draggable pin(color: cyan) may not show up, a restart of App fixed the problem for good, not sure why it happened, but YMMV.

* The walkthrough part is credit to a third party API called *BWWalkthrough*, links: [https://github.com/ariok/BWWalkthrough](https://github.com/ariok/BWWalkthrough)

* I was trying to display airport arrival information on the airport details page, but it turns out that they don't offer airport information API access free of charge, it's in sort of contract form. The notification mechanism and AirportInfo.swift was prepared for this part originally.

