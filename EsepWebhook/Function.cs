using System.Text;
using Amazon.Lambda.Core;
using Newtonsoft.Json;

[assembly: LambdaSerializer(
    typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer)
)]

namespace EsepWebhook;

public class Function
{
    private static readonly HttpClient client = new HttpClient();

    public string FunctionHandler(object input, ILambdaContext context)
    {
        context.Logger.LogLine($"Received: {input}");

        dynamic json = JsonConvert.DeserializeObject<dynamic>(input.ToString());
        string issueUrl = json.issue?.html_url;
        if (issueUrl == null)
            return "ignored";

        string payload = JsonConvert.SerializeObject(new { text = $"Issue Created: {issueUrl}" });
        var content = new StringContent(payload, Encoding.UTF8, "application/json");
        var response = client
            .PostAsync(Environment.GetEnvironmentVariable("SLACK_URL"), content)
            .Result;
        return response.Content.ReadAsStringAsync().Result;
    }
}
