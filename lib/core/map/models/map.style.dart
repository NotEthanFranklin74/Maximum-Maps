enum MapStyle {
  light,
  dark,
}

extension MapStyleExtension on MapStyle {
  String get url {
    switch (this) {
      case MapStyle.light:
        return 'https://tiles.openfreemap.org/styles/liberty';
      case MapStyle.dark:
        return 'https://gist.githubusercontent.com/monkaCode/58289d311ad1321f4307c267af88f130/raw/osm-liberty-dark.json';
    }
  }

  String get displayName {
    switch (this) {
      case MapStyle.light:
        return 'Light';
      case MapStyle.dark:
        return 'Dark';
    }
  }
}