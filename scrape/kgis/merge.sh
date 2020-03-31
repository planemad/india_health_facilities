#!/usr/bin/env bash

mkdir -p output

layer=sub_center
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                geometry,
                SCEName as name,
                'SCE' as type,
                replace( SCEName,'SubCenter, ','') as place,
                'kgis' as source,
                '${layer}' as layer,
                KGISVillageID as village_id,
                KGISCode as source_id
                from $filename"
    break 1
done

layer=primary_health_centre
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    # ogrinfo "$file" -so -al
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                \"HEALTH.DBO.PHC.PHCName\" as name,
                \"HEALTH.dbo.PHC_TBL.ServicesType\" as type,
                \"HEALTH.dbo.PHC_TBL.CategoryName\" as category,
                \"HEALTH.dbo.PHC_TBL.BedCount\" as capacity,
                null as place,
                null as url,
                'kgis' as source,
                '${layer}' as layer,
                \"HEALTH.DBO.PHC.KGISVillageID\" as village_id,
                \"HEALTH.DBO.PHC.KGISCode\" as source_id
                from $filename"
    break 1
done

layer=community_health_centre
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                \"HEALTH.DBO.CHC.CHCName\" as name,
                \"HEALTH.DBO.CHC_TBL.ServicesType\" as type,
                \"HEALTH.DBO.CHC_TBL.CategoryName\" as category,
                \"HEALTH.DBO.CHC_TBL.BedCount\" as capacity,
                \"HEALTH.DBO.CHC_TBL.SubDistrictName\" || ' Subdistrict' as place,
                \"HEALTH.DBO.CHC_TBL.Photo_Link\" as url,
                'kgis' as source,
                '${layer}' as layer,
                \"HEALTH.DBO.CHC.KGISVillageID\" as village_id,
                \"HEALTH.DBO.CHC.KGISCode\" as source_id
                from $filename"
    break 1
done

layer=taluk_hospital
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                \"HEALTH.DBO.THO.THOName\" as name,
                'THO' as type,
                \"HEALTH.DBO.THO_TBL.CategoryName\" as category,
                \"HEALTH.DBO.THO_TBL.BedCount\" as capacity,
                case
                    when \"HEALTH.DBO.THO.THOName\" like '%TALUK%'
                    then replace(replace(replace(replace(\"HEALTH.DBO.THO.THOName\",' Hospital',''),', (FRU)',''),'TALUKA',''),'TALUK','')
                    else null 
                end as place,
                \"HEALTH.DBO.THO_TBL.Photo_Link\" as url,
                'kgis' as source,
                '${layer}' as layer,
                \"HEALTH.DBO.THO.KGISVillageID\" as village_id,
                \"HEALTH.DBO.THO.KGISCode\" as source_id
                from $filename"
    break 1
done

layer=district_hospital
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                \"HEALTH.DBO.DHO.DHOName\" as name,
                'DHO' as type,
                \"HEALTH.DBO.DHO_TBL.CategoryName\" as category,
                \"HEALTH.DBO.DHO_TBL.BedCount\" as capacity,
                \"HEALTH.DBO.DHO_TBL.SubDistrictName\" as place,
                \"HEALTH.DBO.DHO_TBL.Photo_Link\" as url,
                'kgis' as source,
                '${layer}' as layer,
                \"HEALTH.DBO.DHO.KGISVillageID\" as village_id,
                \"HEALTH.DBO.DHO.KGISCode\" as source_id
                from $filename"
    break 1
done

layer=tertiary_health_center
for file in "${layer}/"*.geojson; do
    echo "Processing ${file}"
    filename=$(basename "$file")
    filename=${filename%.*}
    rm "output/${layer}.geojson"
    ogr2ogr "output/${layer}.geojson" "$file" -dialect SQLite\
        -sql "select 
                geometry,
                THCName as name,
                'THC' as type,
                null as category,
                null as capacity,
                null as place,
                'kgis' as source,
                '${layer}' as layer,
                KGISVillageID as village_id,
                KGISCode as source_id
                from $filename"
    break 1
done


cd output
outputfile=karnataka_health_facilities_kgis
rm $outputfile.geojson
for file in *.geojson
do
  if [ -f  tmp.gpkg ]
    then
      ogr2ogr tmp.gpkg $file -update -append 
    else
      
      ogr2ogr tmp.gpkg $file
  fi
done
rm $outputfile.geojson
ogr2ogr $outputfile.geojson tmp.gpkg
rm tmp.gpkg
cd ..