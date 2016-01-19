using Autodesk.Adn.InfraworksService.Models;
using Autodesk.Adn.InfraworksService.Models.Geometries;
using Autodesk.Adn.InfraworksService.Service;
//using Autodesk.Adn.InfraworksService.Service;
//using Autodesk.ADN.Infraworks360Service.Models;
//using Autodesk.ADN.Infraworks360Service.Models.Geometries;
using FourSquare.SharpSquare.Core;
using FourSquare.SharpSquare.Entities;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace WebApplication1
{
  /// <summary>
  /// Summary description for iw360methods
  /// </summary>
  [WebService(Namespace = "http://tempuri.org/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  //[System.ComponentModel.ToolboxItem(false)]
  [System.Web.Script.Services.ScriptService]
  public class IW360Methods : System.Web.Services.WebService
  {
    private const string FOURSQUARE_CLIENTID = "your foursquare client id here";
    private const string FOURSQUARE_CLIENTSECRET = "your goursquare client secret here";

    [WebMethod(EnableSession = true)]
    public bool IsLogged()
    {
      return IW360OAuth.IsAuthorized;
    }

    public InfraworksRestService IW360Service
    {
      get { return new InfraworksRestService(IW360OAuth.CONSUMER_KEY, IW360OAuth.CONSUMER_SECRET, IW360OAuth.OAuthAccessToken, IW360OAuth.OAuthAccessTokenSecret); }
    }

    [WebMethod(EnableSession = true)]
    public Model[] GetModels()
    {
      if (!IW360OAuth.IsAuthorized) return null;
      List<Model> models = IW360Service.GetModels();
      if (models==null) return null;
      return models.ToArray();
    }

    [WebMethod(EnableSession = true)]
    public Model GetModel(string modelId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      return IW360Service.GetModelById(modelId);
    }

    [WebMethod(EnableSession = true)]
    public Collection GetModelRoads(string modelId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Collection roads = IW360Service.GetFeaturesByName(modelId, "master", "roads");
      return roads;
    }

    [WebMethod(EnableSession = true)]
    public Collection GetModelBuildings(string modelId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Collection roads = IW360Service.GetFeaturesByName(modelId, "master", "buildings");
      return roads;
    }

    [WebMethod(EnableSession = true)]
    public Building GetModelBuilding(string modelId, string buildingId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Building building = IW360Service.GetModelFeature(modelId, "master", "buildings", buildingId) as Building;
      return building;
    }

    [WebMethod(EnableSession = true)]
    public double[][] GetBuildingPolygon(string modelId, string buildingId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Building building = GetModelBuilding(modelId, buildingId);
      if (building.geometry.Type != AiwGeometryType.Polygon) return null;

      List<double[]> polygon = new List<double[]>();
      AiwPolygon pl = building.geometry as AiwPolygon;
      foreach (AiwLineString ls in pl.LinearRings)
      {
        foreach (AiwCoordinate coord in ls.Coordinates)
        {
          polygon.Add(new double[] { coord.Y, coord.X });
        }
      }
      return polygon.ToArray<double[]>();
    }

    [WebMethod(EnableSession = true)]
    public List<FourSquareDataModel.Venue> GetVenuesNearBuilding(string modelId, string buildingId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Building building = GetModelBuilding(modelId, buildingId);
      if (building.geometry.Type != AiwGeometryType.Polygon) return null;

      // from the polygon of the building on IW360,
      // let calculate the center point (avarage)
      AiwPolygon pl = building.geometry as AiwPolygon;
      int i = 0;
      double avarageLat = 0;
      double avarageLng = 0;
      foreach (AiwLineString ls in pl.LinearRings)
      {
        foreach (AiwCoordinate coord in ls.Coordinates)
        {
          avarageLat += coord.Y;
          avarageLng += coord.X;
          i++;
        }
      }
      avarageLat /= i;
      avarageLng /= i;

      // now use the avarage point to get venus from Four Square
      SharpSquare square = new SharpSquare(FOURSQUARE_CLIENTID, FOURSQUARE_CLIENTSECRET);
      Dictionary<string, string> requestParams = new Dictionary<string, string>();
      requestParams.Add("ll", string.Format(new CultureInfo("en-US"), "{0},{1}", avarageLat, avarageLng));
      requestParams.Add("radius", "500");
      requestParams.Add("intent", "browse");
      List<Venue> venues = square.SearchVenues(requestParams);

      // the venus from Four Square will come with lots of data
      // let's simplify and add some interesting data
      List<FourSquareDataModel.Venue> simplifiedVenues = new List<FourSquareDataModel.Venue>();
      foreach (Venue v in venues)
      {
        FourSquareDataModel.Venue venueSummary = new FourSquareDataModel.Venue();
        venueSummary.name = v.name;
        venueSummary.id = v.id;
        venueSummary.distance = v.location.distance;
        venueSummary.address = v.location.address;
        venueSummary.url = v.url;
        venueSummary.foursqlat = v.location.lat;
        venueSummary.foursqlng = v.location.lng;
        venueSummary.iw360lat = avarageLat;
        venueSummary.iw360lng = avarageLng;

        simplifiedVenues.Add(venueSummary);
      }

      // and finally order by distance from the center of the building
      var simplifiedVenuesOrder = from FourSquareDataModel.Venue v in simplifiedVenues orderby v.distance ascending select v;

      return simplifiedVenuesOrder.ToList(); // will serialize to JSON
    }

    [WebMethod(EnableSession = true)]
    public string[] GetModelBuildingSummary(string modelId, string buildingId)
    {
      if (!IW360OAuth.IsAuthorized) return null;
      Building building = GetModelBuilding(modelId, buildingId);
      if (building == null || string.IsNullOrWhiteSpace( building.name)) return new string[] { "[Not defined]", string.Empty };
      return new string[] { building.name, building.description.ToString() };
    }
  }
}