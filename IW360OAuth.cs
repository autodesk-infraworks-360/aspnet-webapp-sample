using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using RestSharp;
using RestSharp.Authenticators;
using System.Net;

namespace WebApplication1
{
  public class IW360OAuth
  {
    // Hard coded consumer and secret keys and base URL.
    // In real world Apps, these values need to secured and
    // preferably not hardcoded.
    public const string CONSUMER_KEY = "your key here";
    public const string CONSUMER_SECRET = "your secret here";
    public const string BASE_OAUTH_URL = "https://accounts.autodesk.com";

    //you need to change the domain name and port number if you are using different ones.
    public static string CALLBACK_URL
    {
      get
      {
        return string.Format("http://{0}/callback.aspx", HttpContext.Current.Request.Url.Authority);
      }
    }

    //public static RestClient Client { get; set; }

    private static string OAuthReqToken { get { return (string)HttpContext.Current.Session["OAuthReqToken"]; } set { HttpContext.Current.Session["OAuthReqToken"] = value; } }
    private static string OAuthReqTokenSecret { get { return (string)HttpContext.Current.Session["OAuthReqTokenSecret"]; } set { HttpContext.Current.Session["OAuthReqTokenSecret"] = value; } }

    public static string OAuthAccessToken { get { return (string)HttpContext.Current.Session["OAuthAccessToken"]; } set { HttpContext.Current.Session["OAuthAccessToken"] = value; } }
    public static string OAuthAccessTokenSecret { get { return (string)HttpContext.Current.Session["OAuthAccessTokenSecret"]; } set { HttpContext.Current.Session["OAuthAccessTokenSecret"] = value; } }

    public static string SessionHandle { get { return (string)HttpContext.Current.Session["SessionHandle"]; } set { HttpContext.Current.Session["SessionHandle"] = value; } }
    public static string Verifier { get { return (string)HttpContext.Current.Session["verifier"]; } set { HttpContext.Current.Session["verifier"] = value; } }

    public string LoginURL { get; set; }

    public HttpStatusCode CallLogin()
    {
      RestClient Client = new RestClient(BASE_OAUTH_URL);
      Client.Authenticator = OAuth1Authenticator.ForRequestToken(CONSUMER_KEY, CONSUMER_SECRET, CALLBACK_URL );

      var request = new RestRequest("OAuth/RequestToken", Method.POST);
      var response = Client.Execute(request);

      if (response.StatusCode != HttpStatusCode.OK)
      {
        Client = null;
        return response.StatusCode;
      }
      else
      {
        //get the request token successfully
        //Get the request token and associated parameters.
        var qs = HttpUtility.ParseQueryString(response.Content);
        OAuthReqToken = qs["oauth_token"];
        OAuthReqTokenSecret = qs["oauth_token_secret"];


        //build URL for Authorization HTTP request
        RestRequest authorizeRequest = new RestRequest
        {
          Resource = "OAuth/Authorize",
          Method = Method.GET  //must be GET, POST will cause "500 - Internal server error."
        };
        authorizeRequest.AddParameter("viewmode", "full");
        authorizeRequest.AddParameter("oauth_token", OAuthReqToken);

        Uri authorizeUri = Client.BuildUri(authorizeRequest);
        LoginURL = authorizeUri.ToString();
      }

      return response.StatusCode;
    }

    public static void RequestAccessTokens()
    {
      // Build the HTTP request for an access token
      var request = new RestRequest("OAuth/AccessToken", Method.POST);

      RestClient Client = new RestClient(BASE_OAUTH_URL);
      Client.Authenticator = OAuth1Authenticator.ForAccessToken(
          CONSUMER_KEY, CONSUMER_SECRET, OAuthReqToken, OAuthReqTokenSecret,
          Verifier);


      // Execute the access token request
      var response = Client.Execute(request);
      if (response.StatusCode != HttpStatusCode.OK)
      {
        Client = null;
      }
      else
      {
        // The request for access token is successful. Parse the response and store token,token secret and session handle
        var qs = HttpUtility.ParseQueryString(response.Content);
        OAuthAccessToken = qs["oauth_token"];
        OAuthAccessTokenSecret = qs["oauth_token_secret"];
        SessionHandle = qs["oauth_session_handle"];
      }
    }


    public static bool IsAuthorized
    {
      get
      {
        HttpContext.Current.Session.Timeout = 20;
        return (!string.IsNullOrWhiteSpace(Verifier));
      }
    }

    public static bool IsAccessible
    {
      get
      {
        HttpContext.Current.Session.Timeout = 20;
        return (!string.IsNullOrWhiteSpace(SessionHandle));
      }
    }
  }
}