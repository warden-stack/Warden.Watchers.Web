# Warden Web Watcher

![Warden](http://spetz.github.io/img/warden_logo.png)

**OPEN SOURCE & CROSS-PLATFORM TOOL FOR SIMPLIFIED MONITORING**

**[getwarden.net](http://getwarden.net)**

|Branch             |Build status                                                  
|-------------------|-----------------------------------------------------
|master             |[![master branch build status](https://api.travis-ci.org/warden-stack/Warden.Watchers.Web.svg?branch=master)](https://travis-ci.org/warden-stack/Warden.Watchers.Web)
|develop            |[![develop branch build status](https://api.travis-ci.org/warden-stack/Warden.Watchers.Web.svg?branch=develop)](https://travis-ci.org/warden-stack/Warden.Watchers.Web/branches)


**WebWatcher** can be used either for simple website monitoring or more advanced API monitoring. 

### Installation:

Available as a **[NuGet package](https://www.nuget.org/packages/Warden.Watchers.Web)**. 
```
dotnet add package Warden.Watchers.Web
```

### Configuration:

 - **WithRequest()** - sets the specific *IHttpRequest* type (GET, POST, PUT, DELETE), can be also configured via constructor.
 - **WithTimeout()** - timeout after which the invalid result will be returned.
 - **EnsureThat()** - predicate containing a received *IHttpResponse* that has to be met in order to return a valid result.
 - **EnsureThatAsync()** - async predicate containing a received *IHttpResponse* that has to be met in order to return a valid result.
 - **SkipStatusCodeValidation()** - return a valid result even if the *HttpStatusCode* is not valid (e.g. 400 Bad Request).
 - **WithHttpServiceProvider()** - provide a  custom *IHttpService* which is responsible for making a request (HttpClient is being used by default).

**WebWatcher** can be configured by using the **WebWatcherConfiguration** class or via the lambda expression passed to a specialized constructor.

Example of configuring the watcher via provided configuration class:
```csharp
//Website monitoring
var websiteConfiguration = WebWatcherConfiguration
    .Create("http://httpstat.us/200")
    .Build();
var websiteWatcher = WebWatcher.Create("Website watcher", websiteConfiguration);

//API monitoring
var apiConfiguration = WebWatcherConfiguration
    .Create("http://my-api.com", HttpRequest.Post("users", new {name = "test"},
        headers: new Dictionary<string, string>
        {
            ["Authorization"] = "Token MyBase64EncodedString",
        }))
    .EnsureThat(response => response.Headers.Any())
    .Build();
var apiWatcher = WebWatcher.Create("API watcher", apiConfiguration);

var wardenConfiguration = WardenConfiguration
    .Create()
    .AddWatcher(websiteWatcher)
    .AddWatcher(apiWatcher)
    //Configure other watchers, hooks etc.
```

Example of adding the watcher directly to the **Warden** via one of the extension methods:
```csharp
var wardenConfiguration = WardenConfiguration
    .Create()
    .AddWebWatcher("http://httpstat.us/200")
    .AddWebWatcher("http://my-api.com", HttpRequest.Post("users", new {name = "test"},
        headers: new Dictionary<string, string>
        {
            ["Authorization"] = "Token MyBase64EncodedString",
        }), 
        cfg => cfg.EnsureThat(response => response.Headers.Any())
    )
    //Configure other watchers, hooks etc.
```

Please note that you may either use the lambda expression for configuring the watcher or pass the configuration instance directly. You may also configure the **hooks** by using another lambda expression available in the extension methods.

### Check result type:
**WebWatcher** provides a custom **WebWatcherCheckResult** type which contains additional values.

```csharp
public class WebWatcherCheckResult : WatcherCheckResult
{
    public Uri Uri { get; }
    public IHttpRequest Request { get; }
    public IHttpResponse Response { get; }
}
```

### Custom interfaces:
```csharp
public enum HttpMethod
{
    Get = 1,
    Put = 2,
    Post = 3,
    Delete = 4
}

public interface IHttpRequest
{
    HttpMethod Method { get; }
    string Endpoint { get; }
    object Data { get; }
    IDictionary<string, string> Headers { get; }
}
```

**IHttpRequest** represents the HTTP request that has method type,  endpoint (e.g. "/users" or an empty one if only the base URL is being used), headers and data object if it's required either for POST or PUT operation.

```csharp
public interface IHttpResponse
{
    HttpStatusCode StatusCode { get; }
    bool IsValid { get; }
    string ReasonPhrase { get; }
    IDictionary<string, string> Headers { get; }
    string Data { get; }
}
```

**IHttpResponse** is defined as the response returned by the web server, which contains basic fields such as *StatusCode* or *ReasonPhrase*. If the response has a body (e.g. JSON object), it will be serialized as a string to the *Data* property.

```csharp
public interface IHttpService
{
    Task<IHttpResponse> ExecuteAsync(string baseUrl, IHttpRequest request, TimeSpan? timeout = null);
}
```

**IHttpService** is responsible for making an HTTP request. It can be configured via the *WithHttpServiceProvider()* method. By default it is based on the **[HttpClient](https://msdn.microsoft.com/en-us/library/system.net.http.httpclient(v=vs.118).aspx)**.