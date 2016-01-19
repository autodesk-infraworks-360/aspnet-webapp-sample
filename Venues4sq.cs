using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication1.FourSquareDataModel
{
  public class Venue
  {
    public string id { get; set; }
    public string name { get; set; }
    public double distance { get; set; }
    public string address { get; set; }
    public string url { get; set; }
    public double iw360lat { get; set; }
    public double iw360lng { get; set; }
    public double foursqlat { get; set; }
    public double foursqlng { get; set; }
  }
}