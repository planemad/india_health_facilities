# Health facilities data scraper

Scripts for downloading and processing data.

### From ArcGIS Map Server

- Scripts are organised by data source
- Data for various layers in a `layers.txt` is downloaded using [AGStoShapefile](https://github.com/tannerjt/AGStoShapefile)
- A post processing bash script cleans up the data and combines them to the final geojson

Eg. For KGIS data
```
agsout -s kgis/layers.txt -o ./kgis
./merge.sh
```

